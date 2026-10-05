# Roomies — Rails application

Rails 8.1 · PostgreSQL · Bootstrap 5 (through `cssbundling-rails`).

## Requirements

- Ruby **3.4.5** (see `.ruby-version`; use rbenv, asdf, mise or RubyInstaller)
- PostgreSQL 14 or newer, running locally
- Node.js and Yarn (to build the Bootstrap stylesheet)

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

## Tests

```bash
bin/rails test
```
