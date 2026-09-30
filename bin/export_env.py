#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys
from contextlib import closing

import psycopg2
from psycopg2 import sql


def load_env_file(env_file="env"):
    """Load simple KEY=value entries, preserving embedded equals and quoted values."""
    if not os.path.isfile(env_file):
        return False
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


def start_ssh_service():
    """Start the SSH service if SSH_PORT is set."""
    ssh_port = os.getenv("SSH_PORT")
    if ssh_port:
        subprocess.run(["service", "ssh", "start"], check=True)


def check_env_variables():
    """Ensure required environment variables are set."""
    required_vars = [
        "POSTGRES_USER",
        "DB_DATABASE",
        "DB_USERNAME",
        "DB_PASSWORD",
        "USERNAME",
        "USER_PASSWORD",
    ]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        print(f"Error: Missing environment variables: {', '.join(missing_vars)}")
        sys.exit(1)


def execute_sql(conn, query, params=None):
    """Execute a SQL query."""
    with conn.cursor() as cur:
        cur.execute(query, params)
        conn.commit()


def ensure_database_exists(conn, db_name):
    """Create a missing database with an autocommit maintenance connection."""
    conn.commit()
    original_autocommit = conn.autocommit
    conn.autocommit = True
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
            if cursor.fetchone() is None:
                cursor.execute(
                    sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name))
                )
    finally:
        conn.autocommit = original_autocommit


def ensure_roles_exist(conn, roles):
    """Create missing roles using quoted SQL identifiers and literals."""
    for name, password in roles:
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
    """Grant privileges on the database to specified roles."""
    for role_name in roles:
        query = sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {};").format(
            sql.Identifier(db_name), sql.Identifier(role_name)
        )
        execute_sql(conn, query)


def is_database_empty(conn, db_name):
    """Inspect the requested database instead of the maintenance database."""
    with closing(psycopg2.connect(conn.dsn, dbname=db_name)) as target:
        with target.cursor() as cursor:
            cursor.execute(
                "SELECT NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public')"
            )
            return cursor.fetchone()[0]


def restore_database_dump(db_name, db_username, dump_file="database.dump"):
    """Restore with literal argv and raise if pg_restore fails."""
    if not os.path.isfile(dump_file):
        print(f"Error: {dump_file} file not found. Skipping restore.")
        return False
    subprocess.run(
        ["pg_restore", "--exit-on-error", "-U", db_username, "-d", db_name, dump_file],
        check=True,
    )
    return True


def main():
    # Load environment variables
    load_env_file()

    # Start SSH service if needed
    start_ssh_service()

    # Check if startup is enabled
    if os.getenv("STARTUP") != "true":
        return

    # Ensure all required environment variables are set
    check_env_variables()

    # Database connection
    conn = psycopg2.connect(
        dbname="postgres",
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("SERVER_HOST", "localhost"),  # or set your specific host
    )

    try:
        # Create database and roles
        ensure_database_exists(conn, os.getenv("DB_DATABASE"))
        ensure_roles_exist(
            conn,
            [
                (os.getenv("DB_USERNAME"), os.getenv("DB_PASSWORD")),
                (os.getenv("USERNAME"), os.getenv("USER_PASSWORD")),
            ],
        )

        # Grant privileges
        grant_privileges(
            conn,
            os.getenv("DB_DATABASE"),
            [
                os.getenv("DB_USERNAME"),
                os.getenv("USERNAME"),
            ],
        )

        # Check if the database is empty
        if is_database_empty(conn, os.getenv("DB_DATABASE")):
            restore_database_dump(os.getenv("DB_DATABASE"), os.getenv("DB_USERNAME"))
        else:
            print(
                f"The database '{os.getenv('DB_DATABASE')}' is not empty. Skipping restore."
            )

    finally:
        conn.close()


if __name__ == "__main__":
    main()
