# Jump Start Website

An open-source website builder: once installed, every page, menu, image, blog post and setting is made from the site's own admin screens, with no coding. paul-carrick.com (the owner's personal site and portfolio) runs on it, and so does jump-start-website.com (its documentation and support site). The repository is **public** (github.com/PaulCarrick/jump-start-website), so nothing private goes in it.

## Architecture
- **Back end**: Ruby on Rails 8 (Ruby `.ruby-version`, currently 4.0.7), PostgreSQL, Devise for logins, Solid Cache / Queue / Cable, Puma. Models in `app/models` (pages, sections, cells, menu and footer items, blog posts and comments, image files, site setups, users). Public JSON API under `/api/v1` (`config/routes.rb`), admin screens under `/admin`.
- **Front end**: React 18 with TypeScript (new code in `.tsx`/`.ts`; older components are still `.jsx`), mounted through `react-rails`, bundled by esbuild into `app/assets/builds`; Bootstrap 5 styles from `app/assets/stylesheets` (sass + postcss). Components in `app/javascript/components`, API calls in `app/javascript/services`, hooks in `app/javascript/hooks`. Storybook stories in `stories/`.
- **The JavaScript build** (`esbuild.config.mjs`, run by `npm run build` and by `rails assets:precompile`): minified, with React's production build, when `RAILS_ENV` or `NODE_ENV` is `production`; readable otherwise (`bin/dev`, the tests). Production responses are gzipped by `Rack::Deflater` (`config/environments/production.rb`). The JS build also writes `application.css`, so run `npm run build:css` after it. A shell that has loaded `startup/.env` has `RAILS_ENV=production` set and builds the production bundle.
- **Stylesheets** are served with `stylesheet_link_tag :app`, which loads every CSS file under `app/assets`, including `app/assets/builds`. Keep `app/assets/builds` to the `application.*` files: old per-component CSS left there by earlier builds loads on every page (it once hid a missing-bullets problem locally that the server, which had no such files, would have shown).
- **A component used from a view** (`react_component("Name", ...)`, `data-react-class`) must be listed in `components` in `app/javascript/components/index.jsx`. react_ujs finds components only there; minifying renames variables, so its old name-based fallback does not work. To check the production bundle locally: `RAILS_ENV=production npm run build && npm run build:css`, reload the page, then run `npm run build` again.
- **Installer**: Python 3 (`installation/install.py`, `installation/configuration/`), also run through `installation/install.sh` and the Debian package. Other Python helpers: `bin/setup-database.py`, `bin/export_env.py`, `bin/docker-setup`.
- **Containers**: `compose.yml` (rails and database), `Dockerfile-rails`, `Dockerfile-database` and the quickstart variants; `.github/workflows/containers.yml` builds and publishes images to GHCR (`ghcr.io/paulcarrick/jump-start-website-rails` and `-database`, AMD64 and ARM64) when a `v*` tag is pushed. Docker Hub gets a copy by hand once the workflow has finished: `docker buildx imagetools create -t docker.io/paulcarrick/jump-start-website-server:<tag> ghcr.io/paulcarrick/jump-start-website-rails:<tag>` (the Rails image is named `-server` there), and the same for `jump-start-website-database`, for the version tag and `latest`.
- **Content model**: the editable models are bitemporal (`activerecord-temporal`): admin edits are drafts until published (the top bar's Publish opens Review and publish: drafts grouped by page by `PublishingReview`, each group published or discarded as a whole through `Publishing.deploy!(only:)` / `discard!(only:)`; without groups it publishes everything). Read `docs/bitemporal-publishing.md` before changing a model or a migration. One install can serve several sites, each with its own database (`docs/site-databases.md`). The primary database schema is `db/structure.sql` (SQL, not `schema.rb`, because of the temporal triggers).
- **Admin interface** (redesigned in six stages on the `admin-redesign` branch; plan and what each stage built in `docs/admin-redesign-plan.md`, user guide in `docs/admin-guide.md`): its own frame (`layouts/_admin_page.erb`, sidebar in code in `AdminNavigationHelper`), shared lists (`AdminListHelper`), Settings in tabs, Menus (`Admin::MenusController`), the Media library (`ImageUsage` for "Used on"), the page workspace (`PagesController#workspace`, classic editors kept one click away) and Review and publish. Browser behaviour is in Stimulus controllers in `app/javascript/controllers/`. In system specs, wait for a reload whose address does not change with `wait_for_new_page { ... }` (`spec/support/admin_list_helpers.rb`); reading the page mid-reload gives a Selenium "Node ... does not belong to the document" error. The opt-in `spec/e2e` suite still describes the old screens.

## Rich-text editing (Quill 2)
- Every rich-text field uses Quill 2 through `react-quill-new` (not the unmaintained `react-quill`/Quill 1): the admin `HtmlEditor.jsx` (columns, sections, image captions and descriptions, admin blog posts), the public `PostEditor.jsx` and `CommentEditor.jsx`, and the Contact form (`HtmlEditor` with `simpleToolbar`, writing to a hidden `contact[message]` field). Trix and ActionText's front end were removed.
- Take Quill from the package (`import ReactQuill, { Quill } from "react-quill-new"`) so custom formats register on the same copy.
- Quill 2's clean HTML (`getSemanticHTML`) turns every space into `&nbsp;`. Pass HTML through `storableHtml` (`components/quillHtml.js`) where it leaves the editor (sent, saved, shown in the HTML view), never back into the editor's own `value` (the editor would reload and the cursor jump).
- Quill's stylesheet is `app/assets/stylesheets/quill.snow.css` (Quill 2.0.3 plus the site's own rules at the end). `app/assets/quill/quill.snow.css` is a second copy (a hard link on the owner's Mac, two separate files in git and on the server): keep both identical.
- Saved text is shown in `.ql-editor.rich-text-content` boxes. Quill 2's stylesheet hides list markers there, so `style.css` gives `ul`/`ol` normal bullets and numbers; keep those rules.

## Security rules (from the 2026-11-08 review)
- **HTML from visitors** (blog comments, contact messages) is cleaned on save with `HtmlCleaner.clean` (`app/services/html_cleaner.rb`, an allowlist). Admin-written content (pages, columns, blog posts) is shown as written on purpose.
- **Comments** record their writer (`post_comments.user_id`); the server sets the writer, author and date, and only the writer or an administrator may edit or delete a comment (`PostComment#changeable_by?`).
- **Sign-up is closed**: `User` has no `:registerable`. Administrators add users under Admin > Users; "Forgot your password" still works.
- **Deleting needs a real DELETE request** with the security token: use the `delete_button` helper (or a form with `method: :delete`), never a plain link. There are no `GET .../delete` routes. The one remaining state change by plain link, cancelling Add Section (`pages#edit` with `canceled=true`), may only remove a never-published section of that page.
- **Menu and footer items** validate their links with `SafeLink` (no `javascript:`/`data:` addresses), whole-number orders and labels up to 60 characters. Header and footer hide `/admin` links and admin-only items from anyone who cannot use the admin area (`hidden_navigation_item?` in `ApplicationHelper`).
- Visitors never see server error text (contact form failures go to the log only), and an invalid `page` number is ignored rather than raising.

## Documentation in the repository
- `README.md`, `INSTALLATION.md` (Debian package, Docker, source)
- `docs/`: `admin-guide.md`, `new-site-tutorial.md`, `docker.md`, `site-databases.md`, `bitemporal-publishing.md`, `backend-upgrade.md`, `testing.md`
- Keep these true when a feature changes.

## Running locally
- Settings come from `.env` in the repository root (git-ignored). Templates: `example.env` (Rails on the machine) and `docker-example.env` (Docker). Copy one to `.env` and set `DB_PASSWORD` at least. Ruby runs through rbenv on the Mac (`rbenv exec ...`).
- `bin/dev` runs Rails, the esbuild watcher and the CSS watcher (`Procfile.dev`) on port 3000. The owner's usual local server is http://localhost:3001: `rbenv exec ruby bin/rails server --port 3001`.
- Two local databases: `paul-carrick` on port 5432 (the root `.env`; what `bin/dev` and the local server use) and the Docker database `rails` on port 5433 (`startup/.env`; what `bin/load_database.sh` restores into).
- **A copy of production sends real email.** Its Site Setup holds the live SMTP settings, which the contact form uses. Before testing email on a copy, point them elsewhere (for example `update site_setups set smtp_server='127.0.0.1', smtp_port=2525` in the local database, with a local catcher on that port) and start the server with `SMTP_SERVER=127.0.0.1 SMTP_PORT=2525` for Devise's emails.
- Build assets once with `npm run build` and `npm run build:css`.
- Docker quick start: `bin/docker-setup`, then `docker compose up -d --build` (see `docs/docker.md`).

## Testing (see `docs/testing.md`)
- Ruby: `rbenv exec bundle exec rspec` (about 670 examples, 2 minutes, browser tests included; each run uses its own disposable database). Selenium admin flows: `rbenv exec ruby bin/admin-ui-e2e`.
- `bin/backend-specs` currently reports false failures (its test database starts with Site Setup rows, and one spec expects a `jump_start_rspec_` database name); use `rspec` instead until it is fixed.
- Python (installer and Docker builds): `python3 -m unittest discover -s spec/python -v`
- JavaScript: `./node_modules/.bin/vitest run --config spec/javascript/admin_editors.config.js` (the tests mock `react-quill-new`).
- Lint: `bin/rubocop`, `./node_modules/.bin/eslint app/javascript` (clean), `./node_modules/.bin/tsc --noEmit -p tsconfig.json`; security scan: `bin/brakeman`.

## Database changes
- Adding a column to a bitemporal table: drop the versioning hook, add the column to the table **and** its `_history` table, then recreate the hook (see `db/migrate/20261108120000_add_user_to_post_comments.rb`).
- After `rails db:migrate` against a copy of production, `db/structure.sql` also picks up differences in that copy (CHECK constraint formatting, `content_type NOT NULL` on sections). Commit only the changes the migration made; restore the rest with `git checkout db/structure.sql` and re-apply just those.
- Each extra site has its own database: after `rails db:migrate`, run `rails site_databases:migrate`.

## Conventions
- No abbreviations in variable, function, or method names.
- 2-space indentation in Ruby, TypeScript, JavaScript, JSON and YAML; follow the formatter's default for Python (PEP 8, 4 spaces).
- New front-end code in TypeScript (`strict` is on in `tsconfig.json`).
- Keep solutions simple and direct; avoid unnecessary abstractions.
- Show complete files/functions when making changes.

## Secrets and private files (the repository is public)
- Never commit secrets: `.env*`, `config/master.key`, `config/credentials/*.key`, `certs/`, `secrets/` are git-ignored; keep it that way. Settings that need a value go in the env templates with a placeholder, never the real value.
- SMTP and reCAPTCHA settings live in the Site Setup records in the database (and its history), not in the code; treat database dumps and backups as sensitive.
- The résumés in the repository root (`Resume-PaulCarrick*.docx` / `.pdf`) are public on purpose (the owner decided on 2026-11-08). Other personal files in the working folder, such as `settings.zip`, are untracked: never `git add` them, and never use `git add -A` or `git add .` here; add files by name.
- `installation/dump.sql` is shipped starter data: it must hold no real accounts, passwords or private content.

## Production server (paul-carrick.com)
- Amazon Lightsail, `ssh paul@paul-carrick.com` (key login). The site runs from `~/src/jump-start-website` (`~/jump-start-website` is a link to it) as the systemd service `jumpstartwebsite` (`bin/start_server.sh`, Puma on port 4000 in production) behind nginx; `sudo -n systemctl restart jumpstartwebsite` works without a password. Ruby comes from RVM: `source ~/.rvm/scripts/rvm && rvm use ruby-4.0.7`.
- `bin/start_server.sh` has a server-only edit (bash, loads RVM) that is not in git; `git pull` keeps it as long as the file is not changed upstream.
- The databases run in Docker on the server, port 5433: `rails` (the main site) and `jump-start` (the second site). Their settings are in `startup/.env`; Rails reads the root `.env`. Uploaded images live in `storage`, a link to the Docker volume `jump_start_server_storage`.
- HTTPS: an SSL.com certificate for `paul-carrick.com` only (not `www`), valid until 2027-04-11. DNS is at Network Solutions; the domain's email (MX) is Network Solutions' mail service.

## Deploying
- Push to `main` first: the server deploys what is on GitHub. Then on the server, in `~/src/jump-start-website`:
  1. When a migration changes data: back up first, `set -a; . startup/.env; set +a; PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_DATABASE" -F c -f ~/rails_database_before_<change>.dump`
  2. `git pull --ff-only`
  3. When `package.json` changed: `npm ci` (the asset build fails without the new packages)
  4. Load RVM and the root `.env` (`set -a; . ./.env; set +a`), then `bundle exec rails db:migrate` and `bundle exec rails site_databases:migrate` when there are migrations
  5. `bundle exec rails assets:precompile`
  6. `sudo -n systemctl restart jumpstartwebsite` (about 10 to 15 seconds of downtime), then check https://paul-carrick.com/home
- Releases of the installable images: push a `v*` tag to build and publish the container images to GHCR, then copy them to Docker Hub (see Containers above). Update the version in `INSTALLATION.md` and `docs/docker.md` when releasing.

## Backups
- `bin/backup_database.sh INCLUDE_STORAGE` on the server (export `PGPASSWORD` from `startup/.env` first; the script does not) writes `~/rails_database_<date>.dump` and `~/rails_images_<date>.tar.gz` (about 1.3 GB).
- `bin/load_database.sh INCLUDE_STORAGE` on the Mac copies them down, saves the local Docker database and `storage/` first, then restores into the Docker database (port 5433) and `storage/`. To refresh the `paul-carrick` database on 5432 too, restore the same dump into it with `pg_restore --no-owner`, then run `rails db:migrate` and redirect its email (see Running locally).

## Related project
- Bible and Beyond (`~/src/bible-and-beyond.com`) is a separate project; its contact form uses the paul-carrick.com mail server. Do not change it from here.
