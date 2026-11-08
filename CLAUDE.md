# Jump Start Website

An open-source website builder: once installed, every page, menu, image, blog post and setting is made from the site's own admin screens, with no coding. paul-carrick.com (the owner's personal site and portfolio) runs on it, and so does jump-start-website.com (its documentation and support site). The repository is **public** (github.com/PaulCarrick/jump-start-website), so nothing private goes in it.

## Architecture
- **Back end**: Ruby on Rails 8 (Ruby `.ruby-version`, currently 4.0.7), PostgreSQL, Devise for logins, Solid Cache / Queue / Cable, Puma. Models in `app/models` (pages, sections, cells, menu and footer items, blog posts and comments, image files, site setups, users). Public JSON API under `/api/v1` (`config/routes.rb`), admin screens under `/admin`.
- **Front end**: React 18 with TypeScript (new code in `.tsx`/`.ts`; older components are still `.jsx`), mounted through `react-rails`, bundled by esbuild into `app/assets/builds`; Bootstrap 5 styles from `app/assets/stylesheets` (sass + postcss). Components in `app/javascript/components`, API calls in `app/javascript/services`, hooks in `app/javascript/hooks`. Storybook stories in `stories/`.
- **The JavaScript build** (`esbuild.config.mjs`, run by `npm run build` and by `rails assets:precompile`): minified, with React's production build, when `RAILS_ENV` or `NODE_ENV` is `production`; readable otherwise (`bin/dev`, the tests). Production responses are gzipped by `Rack::Deflater` (`config/environments/production.rb`). The JS build also writes `application.css` (Quill's styles), so run `npm run build:css` after it.
- **A component used from a view** (`react_component("Name", ...)`, `data-react-class`) must be listed in `components` in `app/javascript/components/index.jsx`. react_ujs finds components only there; minifying renames variables, so its old name-based fallback does not work. To check the production bundle locally: `RAILS_ENV=production npm run build && npm run build:css`, reload the page, then run `npm run build` again.
- **Installer**: Python 3 (`installation/install.py`, `installation/configuration/`), also run through `installation/install.sh` and the Debian package. Other Python helpers: `bin/setup-database.py`, `bin/export_env.py`, `bin/docker-setup`.
- **Containers**: `compose.yml` (rails and database), `Dockerfile-rails`, `Dockerfile-database` and the quickstart variants; `.github/workflows/containers.yml` builds and publishes images to GHCR when a `v*` tag is pushed.
- **Content model**: the editable models are bitemporal (`activerecord-temporal`): admin edits are drafts until deployed. Read `docs/bitemporal-publishing.md` before changing a model or a migration. One install can serve several sites, each with its own database (`docs/site-databases.md`). The primary database schema is `db/structure.sql` (SQL, not `schema.rb`, because of the temporal triggers).

## Documentation in the repository
- `README.md`, `INSTALLATION.md` (Debian package, Docker, source)
- `docs/`: `admin-guide.md`, `new-site-tutorial.md`, `docker.md`, `site-databases.md`, `bitemporal-publishing.md`, `backend-upgrade.md`, `testing.md`
- Keep these true when a feature changes.

## Running locally
- Settings come from `.env` in the repository root (git-ignored). Templates: `example.env` (Rails on the machine) and `docker-example.env` (Docker). Copy one to `.env` and set `DB_PASSWORD` at least.
- `bin/dev` runs Rails, the esbuild watcher and the CSS watcher (`Procfile.dev`); the site is at http://localhost:3000.
- Build assets once with `npm run build` and `npm run build:css`.
- Docker quick start: `bin/docker-setup`, then `docker compose up -d --build` (see `docs/docker.md`).

## Testing (see `docs/testing.md`)
- Ruby: `rbenv exec bundle exec rspec`; faster backend only: `rbenv exec ruby bin/backend-specs`; Selenium admin flows: `rbenv exec ruby bin/admin-ui-e2e`. Each uses its own disposable database.
- Python (installer and Docker builds): `python3 -m unittest discover -s spec/python -v`
- JavaScript: `./node_modules/.bin/vitest run --config spec/javascript/admin_editors.config.js`
- Lint: `bin/rubocop`, `npx eslint`; security scan: `bin/brakeman`.

## Conventions
- No abbreviations in variable, function, or method names.
- 2-space indentation in Ruby, TypeScript, JavaScript, JSON and YAML; follow the formatter's default for Python (PEP 8, 4 spaces).
- New front-end code in TypeScript (`strict` is on in `tsconfig.json`).
- Keep solutions simple and direct; avoid unnecessary abstractions.
- Show complete files/functions when making changes.

## Secrets and private files (the repository is public)
- Never commit secrets: `.env*`, `config/master.key`, `config/credentials/*.key`, `certs/`, `secrets/` are git-ignored; keep it that way. Settings that need a value go in the env templates with a placeholder, never the real value.
- SMTP and reCAPTCHA settings live in the Site Setup records in the database (and its history), not in the code; treat database dumps and backups as sensitive.
- The owner keeps personal files in the working folder (résumés `Resume-PaulCarrick*.docx` / `.pdf`, `settings.zip`). They are untracked: never `git add` them, and never use `git add -A` or `git add .` here; add files by name.
- `installation/dump.sql` is shipped starter data: it must hold no real accounts, passwords or private content.

## Deploying
- paul-carrick.com runs on Amazon Lightsail behind an HTTPS reverse proxy (`installation/nginx.conf`, systemd unit `installation/jumpstartwebsite.service`). The exact server, access and deploy steps are not written down here yet; add them when known.
- Releases: push a `v*` tag to build and publish the container images.

## Related project
- Bible and Beyond (`~/src/bible-and-beyond.com`) is a separate project; its contact form uses the paul-carrick.com mail server. Do not change it from here.
