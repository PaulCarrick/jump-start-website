# Admin defaults

`bin/rails db:seed` loads the checked-in snapshot in `admin_defaults.json`:
13 menu items (public navigation, three header icon links, and admin links),
5 footer items (the OTHER group and its four links), plus the
default site setup and home page from the local `jump-start` database. The home
page includes its legacy welcome section; the source has no home-page columns.
The legacy bare site URL is normalized to an `https://` URL when created.
Seeds do not query another database at seed time.

Existing navigation is matched by link (and menu type for menu items). Existing
versions, including disabled records and drafts, are left untouched. The default
setup is skipped if a default setup, its configuration name, or its database
already exists. Newly seeded records are live immediately; running seeds does
not deploy pending changes or provision site databases. Home records are matched
by page name/section group, section name, and column name within the section;
existing content is preserved.

The captured setup has an empty SMTP password, so no SMTP environment variable
is needed. If a future snapshot contains a secret placeholder, supply the named
environment variable when creating a fresh setup. Secret values are not checked
into the snapshot.

The setup's database field remains `paul-carrick`, exactly as stored in the
source `jump-start` database; it does not determine which database `db:seed`
connects to. Rails uses its configured database connection.

Business fields and original timestamps are captured. Database IDs, temporal
version/history metadata, and foreign keys into uncopied records are not copied.
Parent relationships are remapped to destination IDs, preserving the OTHER
footer group. Linkless group headings are matched by label as well as link.

## Users

The snapshot includes `guest@jumpstartserver.com` (Guest User, Regular) and
`jump_start@jumpstartserver.com` (jump_start, Admin), with the profile values
from the source database. Set `USER_PASSWORD` before running `bin/rails db:seed`
when either account is missing. Both new accounts use that password. Source
password hashes, reset tokens, and remembered sessions are not copied.
Existing accounts are matched case-insensitively by email across all versions
and are never updated, including their passwords. No password variable is
required when both accounts already exist.
