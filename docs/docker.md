# Docker quick start

Requires Docker Desktop or Docker Engine with Compose, plus Python 3 for the one-time setup command.

From the repository:

```
bin/docker-setup
docker compose up -d --build
docker compose ps
```

Open http://localhost:3000. Read ADMIN_EMAIL and ADMIN_PASSWORD in the private `.env` file and sign in through the site's login link. Use the admin area to change site settings and content. Only one administrator is created; no shared guest password is installed. Existing accounts are preserved on restart.

The first start prepares the primary, cache, queue, and cable databases and creates starter content. Dependencies and assets are installed at image build time. Both containers restart automatically after failure. Check startup with `docker compose logs rails`.

## Downloaded images

The Container release workflow publishes version tags and `latest` to GHCR for AMD64 and ARM64 when a `v*` Git tag is pushed. Make the packages public before advertising anonymous downloads. Publishing is separate from local builds.

Distribute `compose.yml` and `bin/docker-setup` together. Run setup, then add the published image names to `.env` (replace OWNER, REPO, and VERSION with your release):

```
JUMPSTART_RAILS_IMAGE=ghcr.io/OWNER/REPO-rails:VERSION
JUMPSTART_DATABASE_IMAGE=ghcr.io/OWNER/REPO-database:VERSION
```

Then run `docker compose pull` and `docker compose up -d --no-build`. No repository source is needed for that path.

## Storage and upgrades

The database and uploads use separate named Docker volumes. `docker compose down` preserves them; `down -v` deletes them. Keep `.env` with your backups: changing its database password does not change an initialized PostgreSQL account. Back up PostgreSQL with `pg_dump` and copy the uploads volume before upgrading. Pull the next explicit version and run `docker compose up -d --no-build`; Rails applies migrations automatically. Restore backups to roll back incompatible migrations.

## Public hosting

The default binds only to localhost and serves HTTP on port 3000. For public hosting, configure a domain, set SITE_URL, and use an HTTPS reverse proxy that forwards to Rails; set SSL_MODE=true in Compose when HTTPS is in place. Configure trusted forwarding for your proxy. You can also configure Puma certificates explicitly if retaining exactly two containers. Do not expose the default HTTP installation directly to the Internet. The database has no published host port.

## Verification

Run `python3 -m unittest discover -s spec/python -p test_docker_builds.py`. A full integration check uses a separate Compose project with fresh volumes: build, wait for healthy services, sign in, create content/upload a file, restart and confirm persistence, then upgrade against a backup copy of the volumes.

`bin/test-containers` automates the fresh-volume installation, login-page request, administrator checks, and restart persistence in an isolated temporary project. It deletes only its own test volumes when finished. Requires Compose 2.24.4 or newer for the test's port override.
