#!/usr/bin/env python3

# Handle database access

from contextlib import closing
from types import SimpleNamespace

import psycopg2
from psycopg2 import sql

from .utilities import display_message, process_template


class Database:
    def __init__(
        self,
        db_name=None,
        db_user=None,
        db_password=None,
        db_host=None,
        db_port=None,
        autocommit=None,
    ):
        """
        Create a new database instance.

        If at least db_name, db_user, and db_password are provided, a connection will be established.

        Args:
            db_name (str): Database name
            db_user (str): Database user
            db_password (str): Database user password
            db_host (str): Database host
            db_port (str): Database port
            autocommit (bool): Automatically commit changes
        """
        self.db_connection = None
        self.db_cursor = None
        self.connection_parameters = SimpleNamespace()

        if db_name and db_user and db_password:
            self.db_connection = self.establish_database_connection(
                db_name, db_user, db_password, db_host, db_port, autocommit
            )

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close_database_connection()
        return False

    def setup_connection_parameters(
        self, db_name, db_user, db_password, db_host, db_port, autocommit=None
    ):
        """
        Setup connection parameters and return a SimpleNamespace.

        Args:
            db_name (str): Database name
            db_user (str): Database user
            db_password (str): Database user password
            db_host (str): Database host
            db_port (str): Database port
            autocommit (bool): Automatically commit changes
        """
        self.connection_parameters = SimpleNamespace(
            db_name=db_name,
            db_user=db_user,
            db_password=db_password,
            db_host=db_host,
            db_port=db_port,
            autocommit=autocommit,
        )
        return self.connection_parameters

    def establish_database_connection(
        self, db_name, db_user, db_password, db_host, db_port, autocommit=None
    ):
        """
        Establish database connection and return the connection object.

        Args:
            db_name (str): Database name
            db_user (str): Database user
            db_password (str): Database user password
            db_host (str): Database host
            db_port (str): Database port
            autocommit (bool): Automatically commit changes
        Returns:
            Connection object
        """
        self.setup_connection_parameters(
            db_name, db_user, db_password, db_host, db_port, autocommit
        )
        return self.setup_database_connection()

    def setup_database_connection(self):
        """Setup database connection if it does not exist, and return the connection."""
        try:
            if not self.db_connection:
                self.db_connection = psycopg2.connect(
                    dbname=self.connection_parameters.db_name,
                    user=self.connection_parameters.db_user,
                    password=self.connection_parameters.db_password,
                    host=self.connection_parameters.db_host,
                    port=self.connection_parameters.db_port,
                )

            if self.connection_parameters.autocommit:
                self.db_connection.autocommit = self.connection_parameters.autocommit

            if not self.db_cursor:
                self.db_cursor = self.db_connection.cursor()
        except Exception as e:
            display_message(
                119,
                f"Failed to connect to database: {self.connection_parameters.db_name} "
                f"as {self.connection_parameters.db_user} on "
                f"{self.connection_parameters.db_host}:{self.connection_parameters.db_port}. "
                f"Error: {e}.",
            )

        return self.db_connection

    def close_database_connection(self):
        """Close both resources, even if only a connection was established."""
        cursor, connection = self.db_cursor, self.db_connection
        self.db_cursor = self.db_connection = None
        try:
            if cursor is not None:
                cursor.close()
        finally:
            if connection is not None:
                connection.close()

    def check_database_connection(self, parameters=None):
        """Check if a database connection exists. If not, error out."""
        if not self.db_cursor:
            if parameters:
                self.establish_database_connection(
                    parameters.db_database,
                    parameters.db_username,
                    parameters.db_password,
                    parameters.db_host,
                    parameters.db_port,
                )
            else:
                display_message(121, "No database connection has been established.")

    def get_results(self):
        """Return None, one row, or multiple rows from the last query."""
        try:
            rows = self.db_cursor.fetchall()
        except psycopg2.ProgrammingError:
            return None
        except psycopg2.Error as error:
            display_message(122, f"Failed to get results: {error}.")
            return None
        return rows[0] if len(rows) == 1 else rows or None

    def execute_sql_command(
        self, sql_command, commit=False, no_results=False, params=None
    ):
        """
        Execute a single SQL query (the query can be multi-line).

        Args:
            sql_command (str): The SQL command
            commit (bool): Commit changes after execution.
            no_results (bool): Don't expect results.
        """
        results = None

        self.check_database_connection()

        try:
            self.db_cursor.execute(sql_command, params)

            if not no_results and self.db_cursor.rowcount > 0:
                rows = self.db_cursor.fetchall()

                if len(rows) > 1:
                    results = rows
                elif len(rows) == 1:
                    results = rows[0]

            if commit:
                self.db_connection.commit()
        except psycopg2.Error as e:
            display_message(123, f"Error executing SQL: {e}")
        except Exception as e:
            display_message(124, f"Error: {e}")

        return results

    def execute_sql_commands(self, sql_lines, commit=False):
        """
        Execute an array of sql queries

        Args:
            sql_lines (list): The sql commands.
            commit (bool): Commit the changes after executing the sql commands.
        Return:
            The results from the last sql command
        """
        results = None

        self.check_database_connection()

        for sql_line in sql_lines:
            results = self.execute_sql_command(sql_line, False, True)

        if commit:
            self.db_cursor.connection.commit()

        return results

    def process_sql_file(self, sql_file, verbose=False, parameters=None):
        """Execute a complete SQL script so quoted bodies and DO blocks remain intact."""
        self.check_database_connection(parameters)
        try:
            with open(sql_file, encoding="utf-8") as file:
                script = file.read()
        except OSError as error:
            display_message(126, f"Can't read SQL file: {sql_file}. Error: {error}.")
            return
        if not script.strip():
            return
        if verbose:
            display_message(0, f"Executing SQL file: {sql_file}")
        self.execute_sql_command(script, commit=True, no_results=True)

    def process_sql_template(self, sql_file, parameters, commit=False):
        """
        Read template replacing variables and execute an SQL script.

        Args:
            sql_file (str): Path to the SQL file.
            parameters (dict | SimpleNamespace): Parameters to format into the SQL script.
            commit (bool): Commit changes after execution.
        """
        self.check_database_connection(parameters)
        sql_script = process_template(sql_file, parameters)
        self.execute_sql_command(sql_script, commit)

    def create_database_unless_exists(self, db_database, db_username, parameters=None):
        """
        Creates a PostgreSQL database if it does not exist.

        Args:
            db_database (str): Database name
            db_username (str): Database user
            parameters (SimpleNamespace, optional): Parameters to use to log in to the database.
        """
        display_message(0, f"Checking if database {db_database} exists...")
        self.check_database_connection(parameters)

        if not self.execute_sql_command(
            "SELECT datname FROM pg_database WHERE datname = %s", params=(db_database,)
        ):
            display_message(0, f"Creating database {db_database}...")

            # Open a separate connection with autocommit enabled
            temp_connection = psycopg2.connect(
                dbname="postgres",
                user=self.connection_parameters.db_user,
                password=self.connection_parameters.db_password,
                host=self.connection_parameters.db_host,
                port=self.connection_parameters.db_port,
            )
            with closing(temp_connection):
                temp_connection.autocommit = True
                with temp_connection.cursor() as temp_cursor:
                    temp_cursor.execute(
                        sql.SQL("CREATE DATABASE {}").format(
                            sql.Identifier(db_database)
                        )
                    )

            display_message(0, f"Database {db_database} created.")
            display_message(
                0, f"Granting privileges on {db_database} to {db_username}..."
            )
            self.execute_sql_command(
                sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {}").format(
                    sql.Identifier(db_database), sql.Identifier(db_username)
                ),
                commit=True,
            )
            self.execute_sql_command(
                sql.SQL("ALTER DATABASE {} OWNER TO {}").format(
                    sql.Identifier(db_database), sql.Identifier(db_username)
                ),
                commit=True,
            )

        display_message(0, f"Database {db_database} setup complete.")

    def table_exists(self, table_name, schema="public", parameters=None):
        """
        Check to see if a table exists.
        Args:
            table_name (str): Name of the table.
            schema (str, optional): The schema of the table.
            parameters (SimpleNamespace, optional): Parameters to use to log in to the database.
        Returns:
              bool: True if the table exists.
        """
        self.check_database_connection(parameters)

        try:
            with self.db_connection.cursor() as cur:
                cur.execute(
                    """
                    SELECT EXISTS (
                        SELECT 1 FROM pg_tables 
                        WHERE tablename = %s AND schemaname = %s
                    );
                """,
                    (table_name, schema),
                )

                return cur.fetchone()[
                    0
                ]  # Returns True if table exists, False otherwise
        except psycopg2.Error as e:
            display_message(127, f"Error executing SQL: {e}")

    @staticmethod
    def load_sql_file(parameters, sql_file, verbose=False):
        """
        Read and execute an SQL script.

        Args:
            parameters (SimpleNamespace): Parameters to use to log in to the database.
            sql_file (str): Path to the SQL file.
            verbose (bool. optional): Verbose output.
        """
        with Database() as database:
            database.process_sql_file(sql_file, verbose, parameters)

    @staticmethod
    def load_sql_template(parameters, template_file, commit=False):
        """
        Read template replacing variables and execute an SQL script.

        Args:
            template_file (str): Path to the SQL file.
            parameters (dict | SimpleNamespace): Parameters to format into the SQL script.
            commit (bool): Commit changes after execution.
        """
        with Database() as database:
            database.process_sql_template(template_file, parameters, commit)

    @staticmethod
    def safe_create_database(parameters, db_database, db_username):
        """
        Creates a PostgreSQL database if it does not exist.

        Args:
            parameters (SimpleNamespace): Parameters to use to log in to the database.
            db_database (str): Database name
            db_username (str): Database user
        """
        with Database() as database:
            database.create_database_unless_exists(db_database, db_username, parameters)

    @staticmethod
    def does_table_exist(parameters, table_name, schema="public"):
        """Check table existence and always close the temporary connection."""
        with Database() as database:
            return database.table_exists(table_name, schema, parameters)

    @staticmethod
    def is_table_populated(parameters, table_name, schema="public"):
        """Check for rows using a schema-qualified, quoted table identifier."""
        with Database() as database:
            if not database.table_exists(table_name, schema, parameters):
                return False
            try:
                database.db_cursor.execute(
                    sql.SQL("SELECT EXISTS(SELECT 1 FROM {})").format(
                        sql.Identifier(schema, table_name)
                    )
                )
                return database.db_cursor.fetchone()[0]
            except psycopg2.Error:
                return False

    @staticmethod
    def empty_database(parameters, database):
        """Drop public tables in the requested database and close all resources."""
        display_message(0, f"Emptying {database}...")
        try:
            with closing(
                psycopg2.connect(
                    dbname=database,
                    user=parameters.db_username,
                    password=parameters.db_password,
                    host=parameters.db_host,
                    port=parameters.db_port,
                )
            ) as connection:
                connection.autocommit = True
                with connection.cursor() as cursor:
                    cursor.execute(
                        "SELECT tablename FROM pg_tables WHERE schemaname = 'public'"
                    )
                    for (name,) in cursor.fetchall():
                        display_message(0, f"Deleting {name}...")
                        cursor.execute(
                            sql.SQL("DROP TABLE IF EXISTS {} CASCADE").format(
                                sql.Identifier("public", name)
                            )
                        )
                        display_message(0, f"Deleted {name}.")
        except psycopg2.Error as error:
            display_message(128, f"Error emptying {database}: {error}")
            return
        display_message(0, f"{database} emptied successfully.")
