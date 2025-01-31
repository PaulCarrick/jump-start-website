#!/usr/bin/env python3
import os
import sys
import psycopg2
from psycopg2 import sql
import trace

"""tracer = trace.Trace(trace=True, count=False)"""
"""sys.settrace(tracer.globaltrace)"""

def load_env_file(env_file="env"):
    """Load environment variables from a file."""
    if os.path.isfile(env_file):
        with open(env_file) as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    key, value = line.strip().split("=", 1)
                    os.environ[key] = value

def start_ssh_service():
    """Start the SSH service if SSH_PORT is set."""
    ssh_port = os.getenv("SSH_PORT")
    if ssh_port:
        os.system("service ssh start")

def check_env_variables():
    """Ensure required environment variables are set."""
    required_vars = [
        "POSTGRES_USER", "DB_DATABASE", "DB_USERNAME",
        "DB_PASSWORD", "USERNAME", "USER_PASSWORD"
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
    """Ensure the specified database exists."""
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

def ensure_roles_exist(conn, roles):
    """Ensure the specified roles exist."""
    for role_name, role_password in roles:
        query = f"""
        DO $$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '{role_name}') THEN
                EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', '{role_name}', '{role_password}');
            END IF;
        END
        $$;
        """
        execute_sql(conn, query)

def grant_privileges(conn, db_name, roles):
    """Grant privileges on the database to specified roles."""
    for role_name in roles:
        query = sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {};").format(
            sql.Identifier(db_name), sql.Identifier(role_name)
        )
        execute_sql(conn, query)

def is_database_empty(conn, db_name):
    """Check if the database is empty."""
    query = """
    SELECT NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public');
    """
    with conn.cursor() as cur:
        cur.execute(query)
        return cur.fetchone()[0]

def restore_database_dump(db_name, db_username, dump_file="database.dump"):
    """Restore the database from a dump file."""
    if os.path.isfile(dump_file):
        os.system(f"pg_restore -U {db_username} -d {db_name} {dump_file}")
    else:
        print(f"Error: {dump_file} file not found. Skipping restore.")

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
        host=os.getenv("SERVER_HOST", "localhost")  # or set your specific host
    )

    try:
        # Create database and roles
        ensure_database_exists(conn, os.getenv("DB_DATABASE"))
        ensure_roles_exist(conn, [
            (os.getenv("DB_USERNAME"), os.getenv("DB_PASSWORD")),
            (os.getenv("USERNAME"), os.getenv("USER_PASSWORD")),
        ])

        # Grant privileges
        grant_privileges(conn, os.getenv("DB_DATABASE"), [
            os.getenv("DB_USERNAME"),
            os.getenv("USERNAME"),
        ])

        # Check if the database is empty
        if is_database_empty(conn, os.getenv("DB_DATABASE")):
            restore_database_dump(
                os.getenv("DB_DATABASE"), os.getenv("DB_USERNAME")
            )
        else:
            print(f"The database '{os.getenv('DB_DATABASE')}' is not empty. Skipping restore.")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
