# Local regression tests

Run these from the repository root using the Ruby selected by `.ruby-version`:

```sh
rbenv exec bundle exec rspec
rbenv exec ruby bin/backend-specs
rbenv exec ruby bin/admin-ui-e2e
python3 -m unittest discover -s spec/python -v
./node_modules/.bin/vitest run --config spec/javascript/admin_editors.config.js
```

The backend runner creates a uniquely named local PostgreSQL test database,
loads the schema without development data, runs the backend RSpec files, then
drops that database in `ensure`. It ignores `DATABASE_URL` and Docker overrides
and uses `DB_USERNAME`, `DB_PASSWORD` and `DB_PORT` for the local connection.
Output includes the database name and the directory containing `results.json`
under `tmp/backend-specs/`. A forced process kill can leave that uniquely named
database behind.

Pass paths and RSpec options to run a smaller batch or change the ordering:

```sh
rbenv exec ruby bin/backend-specs spec/models spec/requests
rbenv exec ruby bin/backend-specs --order rand --seed 12345
```

Ordinary `rspec` now runs the backend and system specs against a fresh,
uniquely named local database too. The shared Rails helper sets that database
before loading Rails and drops it on exit. System specs create synthetic site
configuration, a guest user and admin navigation inside each example's
transaction; they never invoke `db:replicate` or copy development uploads.

The faster backend runner excludes `spec/system` and `spec/e2e`. The dedicated
Selenium runner exercises additional admin and public-site flows using its own
disposable database; see [the Selenium guide](../spec/e2e/README.md) for
prerequisites, filtering and screenshot locations. Build current assets with
`npm run build` and `npm run build:css` before ordinary system specs when frontend
code changes; the dedicated Selenium runner builds them automatically.
Ordinary system specs wait up to six seconds for browser state changes; set
`SYSTEM_TEST_WAIT` to override that on a slower machine.

The contact system test substitutes synthetic responses for Google's external
reCAPTCHA client and server verification. It still submits the real browser
form. Request tests separately check missing-token and score/action enforcement.

Obsolete scaffold view checks for nonexistent public cell edit/new/show views
have been replaced by request checks for the current React admin editors,
preview, listing and public column listing. The empty helper placeholder for
the nonexistent `CellsHelper` has been removed. Backend specs contain no
database writes at file-discovery time.

Passing examples are not a code coverage percentage. Coverage instrumentation
and a measured baseline are still required to verify the 80% coverage target.
