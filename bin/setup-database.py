#!/usr/bin/env python3
import os
import sys
import argparse
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
    """Load environment variables from a file."""

    display_message(f"Loading environment variables from {env_file}")

    if os.path.isfile(env_file):
        with open(env_file) as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    key, value = line.strip().split("=", 1)
                    os.environ[key] = value.strip("\"'")
        return True
    elif not missing_okay:
        raise Exception(f"Missing environment file: {env_file}")

    return False


def generate_env_file(args, env_file=".env"):
    """Save environment variables and options to a file."""

    display_message(f"Generating environment variables file: {env_file}")

    # Map environment variables
    environmental_variable_mappings = {
            "POSTGRES_USER":     args.postgres_user or os.getenv(
                    "POSTGRES_USER"),
            "POSTGRES_PASSWORD": args.postgres_password or os.getenv(
                    "POSTGRES_PASSWORD"),
            "POSTGRES_DB":       args.postgres_database or os.getenv(
                    "POSTGRES_DB"),
            "DB_HOST":           args.host or os.getenv("DB_HOST"),
            "DB_PORT":           args.port or os.getenv("DB_PORT"),
            "DB_USERNAME":       args.database_user or os.getenv("DB_USERNAME"),
            "DB_PASSWORD":       args.database_password or os.getenv(
                    "DB_PASSWORD"),
            "DB_DATABASE":       args.database or os.getenv("DB_DATABASE")
    }

    with open(env_file, 'w') as file:
        # Write existing environment variables
        for key, value in os.environ.items():
            # Only overwrite if the key exists in environmental_variable_mappings
            if key in environmental_variable_mappings and \
                    environmental_variable_mappings[key]:
                value = environmental_variable_mappings[key]

            value = str(value)

            if "'" in value:
                file.write(f'{key}="{value}"\n')
            else:
                file.write(f"{key}='{value}'\n")

    # Write additional variables not in os.environ
    for key, value in environmental_variable_mappings.items():
        if key not in os.environ:
            value = str(value)

            if "'" in value:
                file.write(f'{key}="{value}"\n')
            else:
                file.write(f"{key}='{value}'\n")


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
    display_message(f"Creating database if {db_name} exists")

    if force_drop:
        query = f"""
      DO $$
      BEGIN
          PERFORM
              pg_terminate_backend(pg_stat_activity.pid)
          FROM
              pg_stat_activity
          WHERE
              pg_stat_activity.datname = '{db_name}'
              AND pid <> pg_backend_pid();
      END
      $$;
      """
        execute_sql(conn, query)

        query = f"""
          DO $$
          BEGIN
              IF EXISTS (SELECT FROM pg_database WHERE datname = '{db_name}') THEN
                  PERFORM dblink_exec('dbname=postgres', 'DROP DATABASE "{db_name}"');
              END IF;
          END
          $$;
      """
        execute_sql(conn, query)

    query = f"""
        DO $$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '{db_name}') THEN
                PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE "{db_name}"');
            END IF;
        END
        $$;
    """
    execute_sql(conn, query)


def create_roles(conn, roles):
    """Ensure the specified roles exist or create them if they don't exist."""

    display_message("Checking to see if roles exist and if not create them.")

    for role_name, role_password in roles.items():
        if not role_name or not role_password:
            if not display_message(
                    f"Skipping invalid role: name='{role_name}', password='{role_password}'",
                    4):
                display_message(f"Skipping invalid role: name='{role_name}'", 0)

            continue

        if not display_message(
                f"Creating role for '{role_name}' with password '{role_password}'. if it doesn't exist.",
                4):
            display_message(
                    f"Creating role for '{role_name}'if it doesn't exist.", 3)

        query = f"""
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{role_name}') THEN
                    CREATE ROLE "{role_name}" WITH LOGIN PASSWORD '{role_password}';
                END IF;
            END
            $$;
        """
        execute_sql(conn, query)


def grant_privileges(conn, db_name, roles):
    """Grant privileges on the database and public schema to specified roles."""

    display_message("Checking to see if roles exist and if not create them.")

    for role_name in roles:
        if not role_name:
            display_message(f"Skipping invalid role: name='{role_name}'", 0)
            continue

        display_message(f"Granting ALL PRIVILEGES to {role_name} ON {db_name}.",
                        3)

        db_query = sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {};").format(
                sql.Identifier(db_name), sql.Identifier(role_name.strip("\"'"))
        )

        display_message(
                f"Granting CREATE and USAGE PRIVILEGES to {role_name} on public SCHEMA.",
                3)

        schema_query = sql.SQL(
                "GRANT CREATE, USAGE ON SCHEMA public TO {};").format(
                sql.Identifier(role_name.strip("\"'"))
        )

        execute_sql(conn, db_query)
        execute_sql(conn, schema_query)


def is_database_empty(conn, db_name):
    """Check if the specified database is empty."""

    display_message(f"Checking to see if {db_name} exists.", 2)

    query = """
        SELECT NOT EXISTS (
            SELECT 1 FROM pg_tables WHERE schemaname = 'public'
        );
    """
    with conn.cursor() as cur:
        cur.execute(query)
        return cur.fetchone()[0]


def restore_database_dump(database_name, postgres_host, postgres_username, postgres_password,
                          db_username, conn, dump_file="database.dump"):
    """Restore the database from a dump file."""

    if not display_message(f"Restoring {dump_file} to {database_name} as {postgres_username} with password of {postgres_password}.", 4):
        display_message(f"Restoring {dump_file} to {database_name} as {postgres_username}")

    if os.path.isfile(dump_file):
        display_message(f"Setting PGPASSWORD to {postgres_password}", 4)
        os.environ["PGPASSWORD"] = postgres_password
        display_message(f"executing: pg_restore -h {postgres_host} -U {postgres_username} -d {database_name} {dump_file}", 3)
        os.system(f"pg_restore -h {postgres_host} -U {postgres_username} -d {database_name} {dump_file}")

        db_query = f"ALTER DATABASE {database_name} OWNER TO {db_username};"
        execute_sql(conn, db_query)

        db_query = f"""
            DO $$
            DECLARE
             obj RECORD;
            BEGIN
             FOR obj IN
                 SELECT 'ALTER ' || CASE WHEN relkind = 'r' THEN 'TABLE'
                                         WHEN relkind = 'S' THEN 'SEQUENCE'
                                         WHEN relkind = 'v' THEN 'VIEW'
                                         ELSE 'UNKNOWN' END
                        || ' ' || quote_ident(schemaname) || '.' || quote_ident(relname)
                        || ' OWNER TO {db_username};' AS query
                 FROM pg_catalog.pg_class c
                 JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                 WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
                   AND c.relkind IN ('r', 'S', 'v')
                   AND c.relowner = (SELECT oid FROM pg_roles WHERE rolname = '${postgres_username}')
             LOOP
                 EXECUTE obj.query;
             END LOOP;
            END;
            $$;
        """
        execute_sql(conn, db_query)

        return True

    display_message(f"Error: {dump_file} file not found. Skipping restore.", 0)

    return False


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


def parse_arguments():
    """Parse command-line arguments."""
    load_env_file(".env", True)

    parser = argparse.ArgumentParser(
            description="Setup Database databases, roles and import data.")

    parser.add_argument("-v",
                        "--verbose",
                        type=int,
                        help="Verbose output level 1-4 (default: none; * - Level 4 displays passwords).")
    parser.add_argument("-i",
                        "--import-file",
                        type=str2bool,
                        default=False,
                        help="Import database file (default: False).")
    parser.add_argument("-R",
                        "--reprocess",
                        type=str2bool,
                        default=True,
                        help="Process the commands even if the commands were "
                             "previously run (default: True). "
                             "This will probably produce errors if --import is set.")
    parser.add_argument("-F",
                        "--force-drop",
                        action="store_true",
                        help="Force a drop of the target database (dangerous).")
    parser.add_argument("-g",
                        "--generate-env",
                        type=str,
                        default=".env-options",
                        help="Generate .env file from options.")
    parser.add_argument("-e",
                        "--env-file",
                        type=str,
                        default=".env",
                        help="Environment file.")
    parser.add_argument("-f",
                        "--database-file",
                        type=str,
                        default="database.dump",
                        help="The database file to import.")
    parser.add_argument("-H",
                        "--host",
                        type=str,
                        default=os.getenv("DB_HOST", "localhost"),
                        help="Database host.")
    parser.add_argument("-p",
                        "--port",
                        type=int,
                        default=int(os.getenv("DB_PORT", 5432)),
                        help="Database port.")
    parser.add_argument("-u",
                        "--postgres-user",
                        type=str,
                        default=os.getenv("POSTGRES_USER", "postgres"),
                        help="Postgres user.")
    parser.add_argument("-P",
                        "--postgres-password",
                        type=str,
                        default=os.getenv("POSTGRES_PASSWORD"),
                        help="Postgres password.")
    parser.add_argument("-D",
                        "--postgres-database",
                        type=str,
                        default=os.getenv("POSTGRES_DB", "postgres"),
                        help="Postgres password.")
    parser.add_argument("-d",
                        "--database",
                        type=str,
                        default=os.getenv("DB_DATABASE", "jump_start"),
                        help="Database name.")
    parser.add_argument("-U",
                        "--database-user",
                        type=str,
                        default=os.getenv("DB_USERNAME", "postgres"),
                        help="Database user.")
    parser.add_argument("-w",
                        "--database-password",
                        type=str,
                        default=os.getenv("DB_PASSWORD"),
                        help="Database password.")
    parser.add_argument("-r",
                        "--roles",
                        nargs="+",
                        type=parse_key_value,
                        help="Roles in the form USER=PASSWORD.")

    args = parser.parse_args()

    if not args.roles:
        args.roles = {
                os.getenv("DB_USERNAME"): os.getenv("DB_PASSWORD"),
                os.getenv("USERNAME"):    os.getenv("USER_PASSWORD"),
        }

    return args


def check_options(args):
    result = True

    if not args.postgres_user:
        display_message(
                "You must specify a Postgres user either via the POSTGRES_USER environment variable or via --postgres-user.",
                0)
        result = False

    if not args.postgres_password:
        display_message(
                "You must specify a Postgres password either via the POSTGRES_PASSWORD environment variable or via --postgres-password.",
                0)
        result = False

    if not args.postgres_database:
        display_message(
                "You must specify a Postgres database either via the POSTGRES_DB environment variable or via --postgres-database.",
                0)
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
                    0)
            result = False

        if not args.database_password:
            display_message(
                    "You must specify a database password either via the DB_PASSWORD environment variable or via --database-password.",
                    0)
            result = False

        if not args.database:
            display_message(
                    "You must specify a database either via the DB_DATABASE environment variable or via --database.",
                    0)
            result = False

    return result


def main():
    """Main script execution."""
    global verbose

    args = parse_arguments()
    verbose = args.verbose

    if not check_options(args):
        sys.exit(1)

    load_env_file(args.env_file)

    try:
        conn = psycopg2.connect(
                dbname=args.postgres_database,
                user=args.postgres_user,
                password=args.postgres_password,
                host=args.host,
                port=args.port
        )

        if does_database_exist(args.database, conn) and not args.reprocess:
            display_message("Database exists skipping processing.")
            sys.exit(0)

        ensure_dblink_extension(conn)
        create_database(conn, args.database, args.force_drop)
        create_roles(conn, args.roles)
        grant_privileges(conn, args.database, args.roles.keys())

        if args.import_file:
            if is_database_empty(conn, args.database):
                restore_database_dump(args.database,
                                      args.host,
                                      args.postgres_user,
                                      args.postgres_password,
                                      args.database_user,
                                      conn,
                                      args.database_file)
            else:
                display_message(
                        f"The database '{args.database}' is not empty. Skipping restore.")

        if args.generate_env:
            generate_env_file(args, args.generate_env)

    except psycopg2.OperationalError as e:
        display_message(f"Database connection error: {e}")
        sys.exit(2)

    finally:
        if 'conn' in locals() and conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
