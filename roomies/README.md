# Roomies — Rails application

Rails 8.1 · PostgreSQL · Bootstrap 5 (through `cssbundling-rails`).

## Requirements

- Ruby **3.4.5** (see `.ruby-version`; use rbenv, asdf, mise or RubyInstaller)
- PostgreSQL 14 or newer, running locally
- Node.js and Yarn (to build the Bootstrap stylesheet)
- **libvips**, which Active Storage uses to resize listing photographs (`brew install vips` on macOS,
  `sudo apt install libvips` on Ubuntu/WSL)

> **Windows:** we recommend running the project inside WSL 2 (Ubuntu). `bin/dev` relies on `foreman`, which does not run reliably on native Windows.

## Setup

```bash
cd roomies
bundle install
yarn install
```

### Database connection

On macOS with Postgres.app or Homebrew, the default settings work as they are.
If your PostgreSQL needs a host, user or password (Windows, WSL, most Linux installs), export these variables before running any `bin/rails` command:

```bash
export DB_HOST=localhost
export DB_USERNAME=postgres
export DB_PASSWORD=your_password
```

### Create, migrate and seed the database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

To start over from an empty database at any time:

```bash
bin/rails db:reset   # drop, create, load schema and seed
```

## Run the application

```bash
bin/dev
```

`bin/dev` starts the Rails server and the Bootstrap/Sass watcher together (see `Procfile.dev`).
Open <http://localhost:3000>.

## Listing photographs

Hosts upload a listing's photographs from the listing form (several at once), and can remove
them when editing it. They are stored with Active Storage; in development, on disk under
`storage/` (see `config/storage.yml`). The Active Storage tables come with the migrations, so
`bin/rails db:migrate` is the only setup step (no `active_storage:install` needed).

- **Upload limit: 10 MB per photograph.** Only JPEG, PNG and WebP images are accepted, and a
  listing has at most 10 photographs. Both rules are validated in the models
  (`ListingPhoto` and `Listing`); the file field's `accept` attribute is only a convenience.
- **Variants:** the listing cards use a 600×400 `:card` variant and the gallery thumbnails a
  400×300 `:thumb` variant, so a card never downloads the full-resolution file. Only the main
  photo of the listing page uses the larger `:large` variant (at most 1600×1200).
- The seed photographs from Assignment 2 still point to external URLs (`image_url`); they are
  shown as they are, while uploaded photographs go through the variants above.

## Rich text (description and house rules)

A listing's description and house rules are written with Action Text: the listing form shows
a Trix editor with bold, italics, lists and links, and the listing page renders the formatted
HTML. The text is stored in `action_text_rich_texts`; the migration
`MoveListingTextsToActionText` copies the plain text of existing listings there (one paragraph
per `<p>`) and removes the old `listings.description` and `listings.house_rules` columns.
Trix's JavaScript is served by the `actiontext` gem through the import map, so there is nothing
to install: `bin/rails db:migrate` is the only step. File attachments are turned off in the
editor because photographs belong in the listing's photo field.

## Business rules and Hotwire

The rules live in the models (`Listing`, `Application`, `Visit`, `Review`); the views only
show the actions each state allows.

- **Listing lifecycle:** a listing is created as a *draft*, visible only to its host. The host
  publishes it, withdraws it (and can publish it again), and marks it as *rented* once the
  housemate has moved in. Accepting an applicant is what moves it to *reserved*. Only
  published listings take applications.
- **Applications:** a seeker can't apply twice to the same listing nor to their own property.
  The author can withdraw it while it is pending or shortlisted. The host shortlists, rejects
  or accepts it from the application inbox (*Applications → Received*) or from its page.
- **Accepting an applicant** (`Application#accept!`): the application is accepted, every
  other pending or shortlisted application to the listing is rejected, and the listing is
  reserved, in a single transaction with row locks, so if any step fails nothing changes.
  A listing has at most one accepted application (validation + partial unique index).
- **Visits:** proposed only on a shortlisted application, never in the past; a proposed visit
  can be confirmed, rescheduled or cancelled, and a confirmed one completed. Only a completed
  visit enables a review.
- **Turbo Frame:** applying from the listing page replaces only the apply block
  (`application_box` frame) with the confirmation and the state of the application.
- **Turbo Stream:** answering from the inbox replaces the affected rows (on accept, also the
  ones rejected automatically), the pending count and the flash without reloading the page.

## Tests

```bash
bin/rails test
```
