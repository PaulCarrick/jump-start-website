# Python installer regression tests

From the repository root, run:

```sh
python3 -m unittest discover -s spec/python -v
```

Use Python 3.10 or later and the installer's existing `psycopg2-binary` dependency.
Tests use the standard-library `unittest` runner. System commands, curses dialogs,
and PostgreSQL connections are mocked; these tests do not install services or alter
databases.

The tests cover command argument handling and failures, spinner cleanup,
environment file parsing/writing and CLI overrides, database result cardinality,
connection cleanup, quoted SQL identifiers, target database selection, SQL blocks,
debconf template parsing, dialog choice ownership, and Ruby detection.

Optional development checks with Black and Ruff installed:

```sh
black --check bin/*.py installation spec/python
ruff check --no-cache --select F,E9,I bin/*.py installation spec/python
```

A real deployment smoke test on an isolated Linux server is still needed to verify
apt, systemd, debconf, PostgreSQL permissions, and installation orchestration. The
Selenium suite validates the Rails UI and does not exercise these installers.
