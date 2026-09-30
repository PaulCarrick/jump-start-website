#!/usr/bin/env python3
import argparse
import os
import shlex
import subprocess
import sys
from contextlib import closing

import psycopg2
from psycopg2 import sql

verbose = 0


def display_message(message, level=1):
    """
    Display a message if the verbosity level is sufficient.

    Args:
        message (str): The message to display.
        level (int): The verbosity level required to display the message.
    """
    if verbose > (level - 1):
        print(message)


def load_env_file(env_file=".env", missing_okay=False):
    """Load simple KEY=value entries, preserving embedded equals and quoted values."""
    if not os.path.isfile(env_file):
        if not missing_okay:
            raise FileNotFoundError(env_file)
        return False
    with open(env_file, encoding="utf-8") as file:
        for number, line in enumerate(file, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("export "):
                line = line[7:].lstrip()
            key, separator, value = line.partition("=")
            if not separator or not key.strip():
                raise ValueError(f"Invalid environment entry at {env_file}:{number}")
            value = value.strip()
            if value.startswith(("'", '"')):
                tokens = shlex.split(value, comments=False)
                if len(tokens) != 1:
                    raise ValueError(f"Invalid quoted value at {env_file}:{number}")
                value = tokens[0]
            os.environ[key.strip()] = value
    return True


def generate_env_file(args, env_file=".env"):
    """Write the environment with explicit nonempty options overriding existing values."""
    option_names = {
        "POSTGRES_USER": "postgres_user",
        "POSTGRES_PASSWORD": "postgres_password",
        "POSTGRES_DB": "postgres_database",
        "DB_HOST": "host",
        "DB_PORT": "port",
        "DB_USERNAME": "database_user",
        "DB_PASSWORD": "database_password",
        "DB_DATABASE": "database",
    }
    variables = dict(os.environ)
    for key, attribute in option_names.items():
        value = getattr(args, attribute, None)
        if value is not None and value != "":
            variables[key] = str(value)
    with open(env_file, "w", encoding="utf-8") as file:
        for key, value in variables.items():
            file.write(f"{key}={shlex.quote(value)}\n")


def execute_sql(conn, query, params=None):
    display_message(f"executing {query}", 3)

    with conn.cursor() as cur:
        cur.execute(query, params)
        conn.commit()


def ensure_dblink_extension(conn):
    display_message("Checking for existing dblink extension")

    """Ensure the dblink extension is available."""
    query = "CREATE EXTENSION IF NOT EXISTS dblink;"
    execute_sql(conn, query)


def does_database_exist(db_name, conn):
    """Check to see if a database exists."""
    display_message(f"Checking for existence of a database named {db_name}")

    query = "SELECT datname FROM pg_database WHERE datname = %s;"

    with conn.cursor() as cursor:
        cursor.execute(query, (db_name,))
        result = cursor.fetchone()  # Fetch one row

    return result is not None


def create_database(conn, db_name, force_drop=False):
    """Create/drop databases outside a transaction using quoted identifiers."""
    conn.commit()
    original_autocommit = conn.autocommit
    conn.autocommit = True
    try:
        with conn.cursor() as cursor:
            if force_drop:
                cursor.execute(
                    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = %s AND pid <> pg_backend_pid()",
                    (db_name,),
                )
                cursor.execute(
                    sql.SQL("DROP DATABASE IF EXISTS {}").format(
                        sql.Identifier(db_name)
                    )
                )
            if not does_database_exist(db_name, conn):
                cursor.execute(
                    sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name))
                )
    finally:
        conn.autocommit = original_autocommit


def create_roles(conn, roles):
    """Create missing roles without interpolating identifiers or passwords."""
    for name, password in roles.items():
        if not name or not password:
            display_message(f"Skipping invalid role: name='{name}'", 0)
            continue
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", (name,))
            if cursor.fetchone() is None:
                cursor.execute(
                    sql.SQL("CREATE ROLE {} WITH LOGIN PASSWORD {}").format(
                        sql.Identifier(name), sql.Literal(password)
                    )
                )
        conn.commit()


def grant_privileges(conn, db_name, roles):
    """Grant database privileges and schema privileges in the target database."""
    names = [name for name in roles if name]
    for name in names:
        execute_sql(
            conn,
            sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {}").format(
                sql.Identifier(db_name), sql.Identifier(name)
            ),
        )
    with closing(psycopg2.connect(conn.dsn, dbname=db_name)) as target:
        for name in names:
            execute_sql(
                target,
                sql.SQL("GRANT CREATE, USAGE ON SCHEMA public TO {}").format(
                    sql.Identifier(name)
                ),
            )


def is_database_empty(conn, db_name):
    """Check public tables in the target database, not the maintenance database."""
    with closing(psycopg2.connect(conn.dsn, dbname=db_name)) as target:
        with target.cursor() as cursor:
            cursor.execute(
                "SELECT NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public')"
            )
            return cursor.fetchone()[0]


def restore_database_dump(
    database_name,
    postgres_host,
    postgres_username,
    postgres_password,
    db_username,
    conn,
    dump_file="database.dump",
):
    """Restore a dump; propagate command failure before changing ownership."""
    if not os.path.isfile(dump_file):
        display_message(f"Error: {dump_file} file not found. Skipping restore.", 0)
        return False
    environment = {**os.environ, "PGPASSWORD": postgres_password or ""}
    connection_options = conn.get_dsn_parameters()
    subprocess.run(
        [
            "pg_restore",
            "--exit-on-error",
            "-h",
            postgres_host,
            "-p",
            connection_options.get("port", "5432"),
            "-U",
            postgres_username,
            "-d",
            database_name,
            dump_file,
        ],
        env=environment,
        check=True,
    )
    execute_sql(
        conn,
        sql.SQL("ALTER DATABASE {} OWNER TO {}").format(
            sql.Identifier(database_name), sql.Identifier(db_username)
        ),
    )
    with closing(psycopg2.connect(conn.dsn, dbname=database_name)) as target:
        with target.cursor() as cursor:
            cursor.execute(
                "SELECT n.nspname, c.relname, c.relkind FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') AND c.relkind IN ('r', 'S', 'v') AND c.relowner = (SELECT oid FROM pg_roles WHERE rolname = %s)",
                (postgres_username,),
            )
            for schema, name, kind in cursor.fetchall():
                object_type = {"r": "TABLE", "S": "SEQUENCE", "v": "VIEW"}[kind]
                cursor.execute(
                    sql.SQL("ALTER {} {} OWNER TO {}").format(
                        sql.SQL(object_type),
                        sql.Identifier(schema, name),
                        sql.Identifier(db_username),
                    )
                )
        target.commit()
    return True


def str2bool(value):
    """Convert a string to a boolean."""
    if isinstance(value, bool):
        return value
    if value.lower() in {"true", "yes", "y", "1"}:
        return True
    elif value.lower() in {"false", "no", "n", "0"}:
        return False
    raise argparse.ArgumentTypeError(f"Boolean value expected. Got '{value}'.")


def parse_key_value(pair):
    """Parse a key=value pair."""
    try:
        key, value = pair.split("=", 1)
        return key, value
    except ValueError:
        raise argparse.ArgumentTypeError(f"Invalid key=value pair: '{pair}'")


def parse_arguments(argv=None):
    """Parse command-line arguments."""
    environment_parser = argparse.ArgumentParser(add_help=False)
    environment_parser.add_argument("-e", "--env-file", default=".env")
    environment_args, _ = environment_parser.parse_known_args(argv)
    load_env_file(environment_args.env_file, True)

    parser = argparse.ArgumentParser(
        description="Setup Database databases, roles and import data."
    )

    parser.add_argument(
        "-v",
        "--verbose",
        type=int,
        help="Verbose output level 1-4 (default: none; * - Level 4 displays passwords).",
    )
    parser.add_argument(
        "-i",
        "--import-file",
        type=str2bool,
        default=False,
        help="Import database file (default: False).",
    )
    parser.add_argument(
        "-R",
        "--reprocess",
        type=str2bool,
        default=True,
        help="Process the commands even if the commands were "
        "previously run (default: True). "
        "This will probably produce errors if --import is set.",
    )
    parser.add_argument(
        "-F",
        "--force-drop",
        action="store_true",
        help="Force a drop of the target database (dangerous).",
    )
    parser.add_argument(
        "-g",
        "--generate-env",
        type=str,
        default=".env-options",
        help="Generate .env file from options.",
    )
    parser.add_argument(
        "-e", "--env-file", type=str, default=".env", help="Environment file."
    )
    parser.add_argument(
        "-f",
        "--database-file",
        type=str,
        default="database.dump",
        help="The database file to import.",
    )
    parser.add_argument(
        "-H",
        "--host",
        type=str,
        default=os.getenv("DB_HOST", "localhost"),
        help="Database host.",
    )
    parser.add_argument(
        "-p",
        "--port",
        type=int,
        default=int(os.getenv("DB_PORT", 5432)),
        help="Database port.",
    )
    parser.add_argument(
        "-u",
        "--postgres-user",
        type=str,
        default=os.getenv("POSTGRES_USER", "postgres"),
        help="Postgres user.",
    )
    parser.add_argument(
        "-P",
        "--postgres-password",
        type=str,
        default=os.getenv("POSTGRES_PASSWORD"),
        help="Postgres password.",
    )
    parser.add_argument(
        "-D",
        "--postgres-database",
        type=str,
        default=os.getenv("POSTGRES_DB", "postgres"),
        help="Postgres password.",
    )
    parser.add_argument(
        "-d",
        "--database",
        type=str,
        default=os.getenv("DB_DATABASE", "jump_start"),
        help="Database name.",
    )
    parser.add_argument(
        "-U",
        "--database-user",
        type=str,
        default=os.getenv("DB_USERNAME", "postgres"),
        help="Database user.",
    )
    parser.add_argument(
        "-w",
        "--database-password",
        type=str,
        default=os.getenv("DB_PASSWORD"),
        help="Database password.",
    )
    parser.add_argument(
        "-r",
        "--roles",
        nargs="+",
        type=parse_key_value,
        help="Roles in the form USER=PASSWORD.",
    )

    args = parser.parse_args(argv)

    if args.roles:
        args.roles = dict(args.roles)
    else:
        args.roles = {
            args.database_user: args.database_password,
            os.getenv("USERNAME"): os.getenv("USER_PASSWORD"),
        }

    return args


def check_options(args):
    result = True

    if not args.postgres_user:
        display_message(
            "You must specify a Postgres user either via the POSTGRES_USER environment variable or via --postgres-user.",
            0,
        )
        result = False

    if not args.postgres_password:
        display_message(
            "You must specify a Postgres password either via the POSTGRES_PASSWORD environment variable or via --postgres-password.",
            0,
        )
        result = False

    if not args.postgres_database:
        display_message(
            "You must specify a Postgres database either via the POSTGRES_DB environment variable or via --postgres-database.",
            0,
        )
        result = False

    if not args.host:
        display_message("You must specify a server hostname via --host.", 0)
        result = False

    if not args.port:
        display_message("You must specify a server port via --port.", 0)
        result = False

    if args.import_file:
        if not args.database_user:
            display_message(
                "You must specify a database user either via the DB_USERNAME environment variable or via --database-user.",
                0,
            )
            result = False

        if not args.database_password:
            display_message(
                "You must specify a database password either via the DB_PASSWORD environment variable or via --database-password.",
                0,
            )
            result = False

        if not args.database:
            display_message(
                "You must specify a database either via the DB_DATABASE environment variable or via --database.",
                0,
            )
            result = False

    return result


def main():
    """Main script execution."""
    global verbose

    args = parse_arguments()
    verbose = args.verbose or 0

    if not check_options(args):
        sys.exit(1)

    load_env_file(args.env_file)

    try:
        conn = psycopg2.connect(
            dbname=args.postgres_database,
            user=args.postgres_user,
            password=args.postgres_password,
            host=args.host,
            port=args.port,
        )

        if does_database_exist(args.database, conn) and not args.reprocess:
            display_message("Database exists skipping processing.")
            sys.exit(0)

        create_database(conn, args.database, args.force_drop)
        create_roles(conn, args.roles)
        grant_privileges(conn, args.database, args.roles.keys())

        if args.import_file:
            if is_database_empty(conn, args.database):
                restore_database_dump(
                    args.database,
                    args.host,
                    args.postgres_user,
                    args.postgres_password,
                    args.database_user,
                    conn,
                    args.database_file,
                )
            else:
                display_message(
                    f"The database '{args.database}' is not empty. Skipping restore."
                )

        if args.generate_env:
            generate_env_file(args, args.generate_env)

    except subprocess.CalledProcessError as error:
        display_message(f"Database restore failed with exit code {error.returncode}", 0)
        sys.exit(error.returncode or 1)
    except psycopg2.Error as e:
        display_message(f"Database connection error: {e}")
        sys.exit(2)

    finally:
        if "conn" in locals() and conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
