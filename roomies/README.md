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

## Tests

```bash
bin/rails test
```
