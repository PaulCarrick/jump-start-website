# Admin Selenium end-to-end suite

Run from `/Users/paul/src/jump-start-website`:

```sh
bin/admin-ui-e2e
```

This is an opt-in RSpec + Capybara + Selenium suite, separate from the existing `rails_helper` system tests. The existing system hook replicates development data; this suite never invokes it.

## Database lifecycle

The runner overrides `RAILS_ENV=test`, creates a fresh database named `jump_start_ui_e2e_<pid>_<timestamp>_test`, loads the schema without seeds, and drops that database in `ensure` after the run. It removes `DATABASE_URL` and `DOCKERIZED` overrides to avoid accidentally selecting another database. PostgreSQL connection settings still come from the usual DB_HOST, DB_PORT, DB_USERNAME and DB_PASSWORD environment variables.

Before **every example**, the helper verifies the exact disposable database name, truncates its application tables in dependency-safe order, and asserts every application table is empty. It then creates only infrastructure:

- A super user for browser login and a guest user.
- One default site configuration, because there is no first-run installation UI.
- The nine admin sidebar entries, the home/login/gear header entries, and one footer group.

Pages, sections, cells, images, blog posts, extra users, site configurations, and menu/footer items exercised by the tests are created through browser controls. There are no direct HTTP requests, Warden login shortcuts, mocked app APIs or JavaScript injections to write test content. Read-only model assertions verify empty initialization and a few cascade/cleanup outcomes.

Development data, localhost:3000 and the existing test database are not the test target. Capybara launches its own Rails/Puma server on a random local port. Tests and server use the same dedicated database. Test mail uses Rails' test delivery method; SMTP values entered are fake. Uploads use the checked-in sample JPEG and test Active Storage service.

A forced process kill can leave the disposable database behind. Its unique name is printed in the console. Do not run database cleanup against your development database.

## Prerequisites and options

Use the project's installed Ruby/Bundler dependencies and Node modules. The runner rebuilds the JavaScript asset bundle with `npm run build` followed by `npm run build:css` so Selenium sees the current TSX/JS source, not stale browser assets. It does not compile or overwrite the tracked `app/build/typescript` files. PostgreSQL must permit creation of a test database. Chrome and a matching ChromeDriver are needed; Selenium Manager resolves the driver automatically and caches it under `tmp/selenium`.

```sh
# Watch Chrome instead of running headless:
E2E_HEADED=1 bin/admin-ui-e2e

# Optional Firefox/GeckoDriver via Selenium:
E2E_BROWSER=firefox bin/admin-ui-e2e

# Run one group or scenario:
bin/admin-ui-e2e --example 'Site Setups'
bin/admin-ui-e2e --example 'opens Users from'

# Longer waits on slower CI machines:
E2E_WAIT=15 bin/admin-ui-e2e

# Syntax/load check only; this does not execute browser tests:
bin/admin-ui-e2e --dry-run
```

Optional `CHROME_BINARY` or `FIREFOX_BINARY` selects a browser executable. `E2E_ARTIFACTS_DIR` selects the output directory. `--seed` and normal RSpec options can be appended; the default ordering is defined, but examples reset to empty and do not depend on each other's data. The normal RSpec suite does not opt into these destructive test-database resets; use the runner.

## Coverage map

| Area | Browser coverage |
| --- | --- |
| Authentication | Gear entry, login redirect, invalid password, login, Remember me, password visibility, logout |
| Shared shell | All nine sidebar links and empty lists, titles, desktop and narrow-screen navigation, screenshots |
| Site Setups | All form fields, SMTP/authentication, six color controls, social URLs, default checkbox, required fields, second-default validation, create/view/edit/cancel/delete |
| Users | All fields, each access option, roles, duplicate email, required fields, blank password on edit, create/view/edit/cancel/delete |
| Menu Items | Type, label, icon, options, URL, access, numeric order, parent/child selection, create/view/edit/cancel/delete |
| Footer Items | Label, icon, options, URL, access, numeric order, parent/child selection, create/view/edit/cancel/delete |
| Blogs | Author/title/body, visibility/type, creation and saved changes, cancel, deletion, rich text toolbar/inline/list formatting, HTML round trip, each search field and clearing |
| Images | Real upload, MIME selector, immutable existing name, caption/description, group/order, Add to Group select, Add Group list prompt, preview, HTML mode, required fields, CRUD/cancel, each search field, four-item pagination |
| Pages | UI-only creation with generated section/cell, public/admin preview, title edit, cancel, deletion cascades, menu/footer checkbox integration, contextual section/column controls |
| Sections | Add Section regression and temporary-record cancellation, all seven column templates, save/view/edit/cancel/delete, each search control, pagination |
| Cells | Content/name/order/URL, save/view/edit/cancel/delete, HTML mode, margins/background, CSS entry add/edit/delete, image-mode selectors, each search control, pagination |
| Sorting | Every exposed sort column, ascending/descending route state, Clear Sort where exposed, plus visible record order verification on Users |

This maps to the audited admin screens, not to every possible public-site page or every possible formatting-value combination. Search scenarios test matching and missing results for Blogs and Images. Section/Cell filter scenarios cover missing results and restoration; positive image/URL/description filter datasets are not injected into models to bypass their UI limitations. Each column template is tested as a separate example so one broken template does not hide the others. Representative pagination is exercised where the UI has small page limits.

## Results and failure evidence

The runner prints `tmp/admin-ui-e2e/<timestamp>-<pid>`. It writes RSpec `results.json`; failures write PNG screenshots, rendered HTML, the URL and exception text. Navigation and detail screens also have named screenshots. ChromeDriver diagnostics and the isolated browser profile live there. Artifacts contain only synthetic test data.

Assertions describe the intended behavior. Known broken UI flows are **not marked pending**, silently skipped, or made to pass by asserting the broken result. For example, Add Section must eventually expose usable Save/Cancel controls after generation, HTML mode must actually switch, and changed visibility/type must survive reopening Edit. Application failures should be fixed separately, then this suite rerun.

## Verification

The first full browser run completed 82 scenarios: 34 passed and 48 failed. Its evidence is in `tmp/admin-ui-e2e/20260930-071125-99551`. Review found test defects in asset preparation, relative-link matching, numeric field selectors, React input replacement, a validation-text expectation and sort-link filtering. Those have been corrected; the corrected browser suite must be rerun before reporting a new pass/fail count.

Ruby syntax and scenario loading are checked separately. A dry run reporting zero failures is **not** a passing browser run. The first run also reported unresolved editor-content, HTML-mode and persistence failures; these remain assertions rather than being skipped or weakened.

The second full browser run completed 82 scenarios: **53 passed, 29 failed**. Evidence: `tmp/admin-ui-e2e/20260930-075014-3979`. Additional test corrections address existing-field text replacement, image-mode selection, upload boolean attributes and numeric normalization. Another browser run is required to validate those corrections.

The third browser run completed **52 passes and 30 failures** in `tmp/admin-ui-e2e/20260930-081029-6801`. The custom text-entry helper is now explicitly named `fill_field` to avoid Capybara method precedence. Image modes select actual option values, and the narrow-screen button uses its aria-label attribute directly. Syntax passes; browser validation of these corrections remains pending.

## Automatic completion review

Each run now atomically writes `run-status.json` beside its artifacts, including running/finished state, phase, exit code, dry-run flag and database cleanup result. This chat has a one-minute scheduled check named Review completed Selenium runs, which reviews each new real run once and stays quiet otherwise. Keep the computer awake and Codex running. Continue using the same `bin/admin-ui-e2e` command; no manual completion message is needed. Runs started before this runner change do not produce the status marker. A forced kill is detected as an interrupted run when the recorded process is absent.

## Public-site coverage

Eight additional browser examples create or change content through admin controls, clear the browser session, and visit public routes as a guest. They check page titles and body updates, canceled edits, page/section/column deletion, rich-text markup and background formatting, header/footer links and deletion, uploaded image loading and metadata updates, public blog edits/deletion, and private-post visibility on the list, latest view, and direct URL. Image/post IDs are read only to locate public routes; content is still created through the UI.

Run these scenarios with `bin/admin-ui-e2e --example 'public website after admin changes'`, or run the full suite with `bin/admin-ui-e2e`. These checks may reveal application defects that admin previews alone do not expose.
