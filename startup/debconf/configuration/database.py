#!/usr/bin/env python3

# Handle database access

import psycopg2
from psycopg2 import sql
from types import SimpleNamespace
from .utilities import display_message, process_template


class Database:
    def __init__(self,
                 db_name=None,
                 db_user=None,
                 db_password=None,
                 db_host=None,
                 db_port=None,
                 autocommit=None):
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
            self.db_connection = self.establish_database_connection(db_name, db_user, db_password,
                                                                    db_host, db_port, autocommit)


    def setup_connection_parameters(self, db_name, db_user, db_password,
                                    db_host, db_port, autocommit=None):
        """Setup connection parameters and return a SimpleNamespace."""
        self.connection_parameters = SimpleNamespace(db_name=db_name,
                                                     db_user=db_user,
                                                     db_password=db_password,
                                                     db_host=db_host,
                                                     db_port=db_port,
                                                     autocommit=autocommit)
        return self.connection_parameters


    def establish_database_connection(self, db_name, db_user, db_password, db_host,
                                      db_port, autocommit=None):
        """Establish database connection and return the connection object."""
        self.setup_connection_parameters(db_name, db_user, db_password, db_host, db_port, autocommit)
        return self.setup_database_connection()


    def setup_database_connection(self):
        """Setup database connection if it does not exist, and return the connection."""
        try:
            if not self.db_connection:
                self.db_connection = psycopg2.connect(dbname=self.connection_parameters.db_name,
                                                      user=self.connection_parameters.db_user,
                                                      password=self.connection_parameters.db_password,
                                                      host=self.connection_parameters.db_host,
                                                      port=self.connection_parameters.db_port)

            if self.connection_parameters.autocommit:
                self.db_connection.autocommit = self.connection_parameters.autocommit

            if not self.db_cursor:
                self.db_cursor = self.db_connection.cursor()
        except Exception as e:
            display_message(119,
                            f"Failed to connect to database: {self.connection_parameters.db_name} "
                            f"as {self.connection_parameters.db_user} on "
                            f"{self.connection_parameters.db_host}:{self.connection_parameters.db_port}. "
                            f"Error: {e}.")

        return self.db_connection


    def close_database_connection(self):
        """Close database connection."""
        if self.db_connection and self.db_cursor:
            try:
                self.db_cursor.close()
                self.db_connection.close()
                self.db_cursor = None
                self.db_connection = None
            except Exception as e:
                display_message(120, f"Failed to close database connection. Error: {e}.")


    def check_database_connection(self):
        """Check if a database connection exists. If not, error out."""
        if not self.db_cursor:
            display_message(121, "No database connection has been established.")


    def fetch_one(self):
        """Fetch a single row from the last executed query."""
        return self.db_cursor.fetchone()


    def fetch_all(self):
        """Fetch all results from the last executed query."""
        return self.db_cursor.fetchall()


    def execute_sql_command(self, sql_command, results=0, commit=False):
        """
        Execute a single SQL query.

        Args:
            sql_command (str): The SQL command
            results (int): 0 for no return, 1 for a single row, >1 for all rows.
            commit (bool): Commit changes after execution.
        """
        self.check_database_connection()

        try:
            self.db_cursor.execute(sql.SQL(sql_command))

            if commit:
                self.db_connection.commit()
        except psycopg2.Error as e:
            display_message(124, f"Error executing SQL: {e}")
        except Exception as e:
            display_message(125, f"Error: {e}")

        if results > 1:
            return self.fetch_all()
        elif results == 1:
            return self.fetch_one()
        return None


    def execute_sql_commands(self, sql_lines, commit=False):
        """
        Execute an array of sql queries

        Args:
            sql_lines (list): The sql commands.
            commit (bool): Commit the changes after executing the sql commands.
        Return:
            The results from the last sql command
        """
        self.check_database_connection()

        for sql_line in sql_lines:
            self.execute_sql_command(sql_line)

        if commit:
            self.db_cursor.connection.commit()

        return self.get_results()


    def process_sql_template(self, sql_file, params, commit=False):
        """
        Read, format, and execute an SQL script.

        Args:
            sql_file (str): Path to the SQL file.
            params (dict | SimpleNamespace): Parameters to format into the SQL script.
            commit (bool): Commit changes after execution.
        """
        self.check_database_connection()
        sql_script = process_template(sql_file, params)
        self.execute_sql_command(sql_script, commit)


    def create_database_unless_exists(self, db_database, db_username):
        """
        Creates a PostgreSQL database if it does not exist.

        Args:
            db_database (str): Database name
            db_username (str): Database user
        """
        display_message(0, f"Checking if database {db_database} exists...")
        self.check_database_connection()

        self.execute_sql_command(f"SELECT datname FROM pg_database WHERE datname = '{db_database}';", results=1)

        if not self.fetch_one():  # Database does not exist
            display_message(0, f"Creating database {db_database}...")

            # Open a separate connection with autocommit enabled
            temp_connection = psycopg2.connect(dbname="postgres",
                                               user=self.connection_parameters.db_user,
                                               password=self.connection_parameters.db_password,
                                               host=self.connection_parameters.db_host,
                                               port=self.connection_parameters.db_port)
            temp_connection.autocommit = True

            with temp_connection.cursor() as temp_cursor:
                temp_cursor.execute(sql.SQL(f"CREATE DATABASE {db_database};"))

            temp_connection.close()

            display_message(0, f"Database {db_database} created.")
            display_message(0, f"Granting privileges on {db_database} to {db_username}...")
            self.execute_sql_command(f"GRANT ALL PRIVILEGES ON DATABASE {db_database} TO {db_username};", commit=True)
            self.execute_sql_command(f"ALTER DATABASE {db_database} OWNER TO {db_username};", commit=True)

        display_message(0, f"Database {db_database} setup complete.")
