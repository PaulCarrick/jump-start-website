"""Installer regressions; no system services or real databases are touched."""

import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "installation"))
from configuration import rails_support, utilities
from configuration.database import Database
from configuration.dialog import Dialog
from psycopg2 import sql


def script(name):
    spec = importlib.util.spec_from_file_location(
        name.replace("-", "_"), ROOT / "bin" / f"{name}.py"
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


setup = script("setup-database")
export = script("export_env")


class CommandTests(unittest.TestCase):
    @patch.object(utilities.subprocess, "run")
    def test_argument_boundaries_are_preserved(self, run):
        run.return_value = SimpleNamespace(returncode=0, stdout="ok", stderr="")
        self.assertEqual(
            utilities.run_command(["echo", "path with spaces", "$(literal)"]), "ok"
        )
        self.assertEqual(
            run.call_args.args[0], ["echo", "path with spaces", "$(literal)"]
        )
        self.assertFalse(run.call_args.kwargs["shell"])

    @patch.object(utilities.subprocess, "run")
    def test_shell_expressions_remain_supported(self, run):
        run.return_value = SimpleNamespace(returncode=0, stdout="", stderr="")
        self.assertTrue(utilities.run_command("cd /tmp && pwd", capture_output=False))
        self.assertTrue(run.call_args.kwargs["shell"])

    @patch.object(utilities.subprocess, "run")
    def test_user_commands_are_not_nested_in_unsafe_quotes(self, run):
        run.return_value = SimpleNamespace(returncode=0, stdout="ok", stderr="")
        utilities.run_command(["echo", "it's here"], as_user="owner")
        args = run.call_args.args[0]
        self.assertEqual(args[:4], ["su", "-", "owner", "-c"])
        import shlex

        self.assertEqual(shlex.split(args[4]), ["echo", "it's here"])

    @patch.object(utilities.subprocess, "run")
    def test_optional_failures_and_timeouts(self, run):
        run.return_value = SimpleNamespace(returncode=1, stdout="", stderr="error")
        self.assertFalse(
            utilities.run_command(["false"], flag_error=False, capture_output=False)
        )
        run.side_effect = subprocess.TimeoutExpired("test", 1)
        self.assertEqual(utilities.run_command(["test"], timeout=1), "")

    def test_spinner_cleanup_on_system_exit(self):
        stop = MagicMock()
        thread = MagicMock()
        with patch.object(
            utilities.threading, "Event", return_value=stop
        ), patch.object(
            utilities.threading, "Thread", return_value=thread
        ), patch.object(
            utilities, "run_command", side_effect=SystemExit(70)
        ):
            with self.assertRaises(SystemExit):
                utilities.run_long_command("failing")
        stop.set.assert_called_once()
        thread.join.assert_called_once()


class EnvironmentTests(unittest.TestCase):
    def test_loaders_parse_whitespace_exports_and_embedded_equals(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {}, clear=True
        ):
            path = Path(directory) / ".env"
            path.write_text('  # comment\n export VALUE = "a=b"\nEMPTY=\n')
            for module in (setup, export):
                module.load_env_file(path)
                self.assertEqual(os.environ["VALUE"], "a=b")
                self.assertEqual(os.environ["EMPTY"], "")

    def test_missing_and_invalid_env_files(self):
        self.assertFalse(setup.load_env_file("/nonexistent/e2e.env", True))
        with self.assertRaises(FileNotFoundError):
            setup.load_env_file("/nonexistent/e2e.env")
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / ".env"
            path.write_text("bad line\n")
            with self.assertRaisesRegex(ValueError, ":1"):
                export.load_env_file(path)

    def test_env_generation_writes_all_options_inside_file_and_round_trips_quotes(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {"EXISTING": "keep"}, clear=True
        ):
            path = Path(directory) / ".env"
            setup.generate_env_file(
                SimpleNamespace(
                    database="target", database_password="it's a $value", port=5433
                ),
                path,
            )
            setup.load_env_file(path)
            self.assertEqual(os.environ["DB_DATABASE"], "target")
            self.assertEqual(os.environ["DB_PASSWORD"], "it's a $value")
            self.assertEqual(os.environ["DB_PORT"], "5433")
            self.assertNotIn("None", path.read_text())

    def test_roles_options_are_a_mapping(self):
        with patch.object(setup, "load_env_file"), patch.object(
            sys, "argv", ["setup", "--roles", "user=password", "other=a=b"]
        ):
            args = setup.parse_arguments()
        self.assertEqual(args.roles, {"user": "password", "other": "a=b"})


class DatabaseTests(unittest.TestCase):
    def database(self, rows=None):
        database = Database()
        database.db_connection = MagicMock()
        database.db_cursor = MagicMock()
        database.db_cursor.fetchall.return_value = rows or []
        return database

    def test_result_cardinality(self):
        for rows, expected in [
            ([], None),
            ([(1,)], (1,)),
            ([(1,), (2,)], [(1,), (2,)]),
        ]:
            self.assertEqual(self.database(rows).get_results(), expected)

    def test_context_manager_closes_after_failure(self):
        database = self.database()
        cursor = database.db_cursor
        connection = database.db_connection
        with self.assertRaises(RuntimeError):
            with database:
                raise RuntimeError("failed")
        cursor.close.assert_called_once()
        connection.close.assert_called_once()
        self.assertIsNone(database.db_connection)

    def test_connection_closes_even_without_cursor(self):
        database = self.database()
        connection = database.db_connection
        database.db_cursor = None
        database.close_database_connection()
        connection.close.assert_called_once()

    def test_table_check_uses_a_separate_cursor(self):
        database = self.database()
        shared = database.db_cursor
        database.db_connection.cursor.return_value.__enter__.return_value.fetchone.return_value = (
            True,
        )
        self.assertTrue(database.table_exists("some table"))
        shared.__exit__.assert_not_called()

    def test_target_database_is_checked_and_closed(self):
        for module in (setup, export):
            conn = MagicMock()
            target = MagicMock()
            conn.dsn = "mock DSN"
            target.cursor.return_value.__enter__.return_value.fetchone.return_value = (
                True,
            )
            with patch.object(
                module.psycopg2, "connect", return_value=target
            ) as connect:
                self.assertTrue(module.is_database_empty(conn, "target"))
                connect.assert_called_once_with("mock DSN", dbname="target")
                target.close.assert_called_once()

    def test_role_creation_quotes_name_and_password(self):
        conn = MagicMock()
        cursor = conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = None
        setup.create_roles(conn, {"odd name": "it's secret"})
        self.assertEqual(
            cursor.execute.call_args.args[0],
            sql.SQL("CREATE ROLE {} WITH LOGIN PASSWORD {}").format(
                sql.Identifier("odd name"), sql.Literal("it's secret")
            ),
        )
        self.assertEqual(cursor.execute.call_args_list[0].args[1], ("odd name",))

    def test_database_creation_restores_autocommit_on_error(self):
        conn = MagicMock()
        conn.autocommit = False
        with patch.object(setup, "does_database_exist", return_value=False):
            conn.cursor.return_value.__enter__.return_value.execute.side_effect = (
                RuntimeError("failed")
            )
            with self.assertRaises(RuntimeError):
                setup.create_database(conn, "target")
        self.assertFalse(conn.autocommit)

    def test_failed_restore_stops_before_ownership_changes(self):
        conn = MagicMock()
        conn.get_dsn_parameters.return_value = {"port": "5433"}
        with tempfile.NamedTemporaryFile() as dump, patch.object(
            setup.subprocess,
            "run",
            side_effect=subprocess.CalledProcessError(1, "pg_restore"),
        ), patch.object(setup, "execute_sql") as execute, patch.dict(
            os.environ, {"PGPASSWORD": "original"}
        ):
            with self.assertRaises(subprocess.CalledProcessError):
                setup.restore_database_dump(
                    "target", "host", "admin", "secret", "owner", conn, dump.name
                )
            execute.assert_not_called()
            self.assertEqual(os.environ["PGPASSWORD"], "original")


class DialogAndRubyTests(unittest.TestCase):
    def test_select_does_not_reorder_callers_choices(self):
        choices = ["Yes", "No"]

        def select(dialog):
            dialog.status = "Done"
            return dialog.values[0]

        with patch.object(Dialog, "_process_select", select):
            self.assertEqual(Dialog.select("Prompt", choices, "No"), ["No", "Done"])
        self.assertEqual(choices, ["Yes", "No"])

    def test_blank_default_is_not_replaced_with_none(self):
        self.assertEqual(Dialog("Prompt", [None]).values, [""])

    def test_ruby_path_is_a_string(self):
        with patch.object(
            rails_support, "run_command", side_effect=["version", "/ruby/path\n"]
        ):
            self.assertEqual(rails_support.get_ruby_path("owner"), "/ruby/path")

    def test_ruby_four_is_newer_than_three_two(self):
        with patch.object(
            rails_support, "get_ruby_path", return_value="/ruby"
        ), patch.object(rails_support, "run_command", return_value="ruby 4.0.0"):
            self.assertTrue(rails_support.ruby_installed("owner"))


class SqlScriptTests(unittest.TestCase):
    def test_sql_blocks_are_not_split_at_inner_semicolons(self):
        script = "DO $$ BEGIN PERFORM 1; PERFORM 2; END $$;\n"
        database = Database()
        with tempfile.NamedTemporaryFile(mode="w+", suffix=".sql") as file:
            file.write(script)
            file.flush()
            with patch.object(database, "check_database_connection"), patch.object(
                database, "execute_sql_command"
            ) as execute:
                database.process_sql_file(file.name)
                execute.assert_called_once_with(script, commit=True, no_results=True)

    def test_template_choices_and_continuation_lines_are_independent(self):
        from configuration.debconf import DebConf

        text = "Template: test/first\nType: select\nDefault: No\nChoices: Yes,\n No, Quit\nDescription: Choose\n an option\nTemplate: test/second\nType: string\nDefault:\nDescription: Name\n"
        with tempfile.NamedTemporaryFile(mode="w+", suffix=".templates") as file:
            file.write(text)
            file.flush()
            debconf = DebConf(file.name)
            with patch.object(
                debconf, "_DebConf__is_debconf_available", return_value=False
            ):
                debconf.initialize_debconf_environment()
        first = getattr(debconf.templates, "test/first")
        second = getattr(debconf.templates, "test/second")
        self.assertEqual(first.choices, ["Yes", "No", "Quit"])
        self.assertEqual(first.default, "No")
        self.assertEqual(first.description, "Choose an option")
        self.assertEqual(second.default, "")


class ResourceTests(unittest.TestCase):
    def test_schema_privileges_are_granted_in_target_database(self):
        conn = MagicMock()
        conn.dsn = "mock DSN"
        target = MagicMock()
        with patch.object(
            setup.psycopg2, "connect", return_value=target
        ) as connect, patch.object(setup, "execute_sql") as execute:
            setup.grant_privileges(conn, "target", ["owner"])
        connect.assert_called_once_with("mock DSN", dbname="target")
        self.assertIs(execute.call_args_list[0].args[0], conn)
        self.assertIs(execute.call_args_list[1].args[0], target)
        target.close.assert_called_once()

    def test_empty_database_targets_named_database_and_quotes_tables(self):
        params = SimpleNamespace(
            db_database="other",
            db_username="owner",
            db_password="secret",
            db_host="host",
            db_port=5432,
        )
        conn = MagicMock()
        cursor = conn.cursor.return_value.__enter__.return_value
        cursor.fetchall.return_value = [("table with spaces",)]
        with patch(
            "configuration.database.psycopg2.connect", return_value=conn
        ) as connect, patch("configuration.database.display_message"):
            Database.empty_database(params, "target")
        self.assertEqual(connect.call_args.kwargs["dbname"], "target")
        self.assertEqual(
            cursor.execute.call_args.args[0],
            sql.SQL("DROP TABLE IF EXISTS {} CASCADE").format(
                sql.Identifier("public", "table with spaces")
            ),
        )
        conn.close.assert_called_once()


class CliDefaultsTests(unittest.TestCase):
    def test_selected_environment_file_supplies_cli_defaults(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {}, clear=True
        ):
            path = Path(directory) / "custom.env"
            path.write_text(
                "DB_HOST=chosen-host\nDB_PORT=5433\nDB_USERNAME=chosen-user\nDB_PASSWORD=chosen-password\n"
            )
            args = setup.parse_arguments(["--env-file", str(path)])
        self.assertEqual(args.host, "chosen-host")
        self.assertEqual(args.port, 5433)
        self.assertEqual(args.roles, {"chosen-user": "chosen-password", None: None})

    def test_explicit_user_options_supply_default_roles(self):
        with patch.object(setup, "load_env_file"), patch.dict(
            os.environ, {}, clear=True
        ):
            args = setup.parse_arguments(
                ["--database-user", "user", "--database-password", "password"]
            )
        self.assertEqual(args.roles["user"], "password")


if __name__ == "__main__":
    unittest.main()
