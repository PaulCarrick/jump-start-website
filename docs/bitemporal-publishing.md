# Bitemporal publishing and production migration

## Data model

The eleven editable application models use the pinned `activerecord-temporal` 0.4.0 gem. Application versions remain in each existing model table. Each row has `(id, version)` as its database primary key and a PostgreSQL `tstzrange` validity period. The gem maintains a corresponding `*_history` table with a system-time range through database triggers.

Application code keeps scalar logical IDs and existing URLs. Rails `query_constraints :id, :version` ensures that an update affects one physical version. Associations explicitly use the logical ID. Small `*_identities` tables anchor existing foreign keys; they contain only identities, not draft content or another versioning system.

A draft has `temporal_state = draft` and PostgreSQL `EMPTY` validity. It cannot become live merely because time passes. Publishing closes the live application's validity using the gem's API and starts the pending version at one shared deployment time. Source and history exclusion constraints prohibit overlapping periods. Database recording time is maintained by the gem, not supplied by a browser.

New records, edits, renumbering, and deletions in admin are pending. Reads default to live versions, including background jobs. Admin requests explicitly enter the shared workspace, which resolves pending versions for editors; public requests resolve currently valid live rows. Public draft previews require an authenticated administrator. Changes are serialized against deployment/discard, and stale saves are rejected.

Existing application/system timestamps remain independent: `created_at` and `updated_at` are not substitutes for validity and system periods.

`Model.bitemporal_at(valid_at: ..., known_at: ...)` exposes a native gem two-time history query. History records are read-only. Operational updates outside admin, such as password-reset token maintenance and contact submissions, are system-audited immediately; they do not wait for a content deployment.

## Files and credentials

Image replacements use immutable blob IDs on their temporal versions, retaining references so old/draft files are not purged. Uploading a draft must not replace the live image attachment. Treat history, attachments, and backups as sensitive: old password digests and configuration values exist in database history. The UI never renders secret values in review/history, and Restore as Draft excludes credentials and password/reset-token fields.

## Before production

1. Take and verify a restorable PostgreSQL backup and an Active Storage backup. Record the current application release. A database-only restore cannot recover missing attachment bytes.
2. Rehearse against a restored production backup using the exact pinned bundle and PostgreSQL version. The included populated fixture rehearsal is useful, but does not replace testing the actual production schema and data.
3. Confirm PostgreSQL 13+ and availability/permission to install `btree_gist`. A privileged database administrator may install that extension in advance. The migration role must be able to create tables, functions, and triggers; if it differs from the application role, grant the application access to the new tables and sequences before resuming traffic.
4. Review existing unique indexes. The migration supports ordinary unique column indexes and intentionally stops on expressions/partial indexes rather than silently weakening them.
5. Plan a maintenance window. This is a transactional, locking migration, not an online zero-downtime change. Stop web writers and background jobs; do not permit the old application to write after the schema changes.
6. Confirm the deployment image contains `db/structure.sql`. The Ruby schema dumper does not retain the gem's trigger functions. PostgreSQL client tools must be available to load/dump SQL schemas, including in CI. The existing cache, queue, and cable databases explicitly retain their Ruby schema format; only the primary content database switches to SQL.

## Production sequence

With writers stopped and the new release available:

```sh
bundle install
RAILS_ENV=production bundle exec rails db:migrate
```

Use the deployment's normal environment and credentials; do not copy development database settings. The migration never imports development data or assumes development IDs. Existing records keep their IDs, attributes, and timestamps. Their initial application validity begins at their existing creation time; database knowledge begins at migration time. This baseline does not invent pre-migration system history.

The migration is atomic, sets a 10-second lock timeout, creates identity anchors, converts uniqueness rules to temporal exclusion constraints, backfills initial history, and installs native gem hooks. If it fails, investigate and retry while writers remain stopped; do not mark it applied manually.

The new application refuses writes when it still sees the old schema; do not bypass this guard. Restart every application and worker process after migration to clear model/schema caches. Verify:

- Public pages and existing links look unchanged before any edit/deployment.
- Current admins can sign in with existing credentials.
- A saved edit is visible in admin and an authorized draft preview, but not on the public page.
- Deploy Changes publishes the reviewed changes together.
- Discard leaves live content unchanged.
- Existing and replacement image files remain available appropriately.
- History shows both validity and recording periods.

Then resume normal traffic and workers. Preserve the backup and old release according to the site's retention policy.

## Rollback

Automatic `db:rollback` intentionally refuses to collapse temporal data into one version. Before accepting new writes, a failed rollout can be reverted by restoring the verified pre-migration database/files and previous application release. After accepting new writes, use a forward repair or a deliberately reviewed data recovery procedure; blindly restoring the old backup would lose those writes and history.

Content rollback is separate from schema rollback: History → Restore as Draft → review → Deploy Changes creates a new live version without rewriting the past.

## Verification

```sh
RAILS_ENV=test bundle exec rails runner script/verify_temporal_migration.rb
bundle exec rspec
```

The migration rehearsal creates and drops a distinct disposable PostgreSQL database, loads the previous schema, populates all eleven models, runs the real Rails migration command in a fresh process, and checks field values, logical IDs, timestamps, row counts, and history baselines. It does not migrate the caller's database. It requires permission to create/drop that temporary database.

Tests load `db/structure.sql` into isolated databases and exercise draft/public separation, native bitemporal queries, publishing, rejection of stale edits, restoration, deletion, authorization, and attachment retention. PostgreSQL system history describes committed transactions: several corrections within one transaction are one system-time observation.

## Gem compatibility note

Version 0.4.0's history model generator assumes all association scopes implement `temporal_scope?`. The `History` namespace narrowly marks ordinary scopes before delegating to the gem; it does not patch Proc globally. Upgrade the beta only after rerunning association, history, migration, and schema-round-trip checks.
