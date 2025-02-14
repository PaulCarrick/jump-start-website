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
        self.connection_parameters = SimpleNamespace(db_name=db_name,
                                                     db_user=db_user,
                                                     db_password=db_password,
                                                     db_host=db_host,
                                                     db_port=db_port,
                                                     autocommit=autocommit)
        return self.connection_parameters


    def establish_database_connection(self, db_name, db_user, db_password, db_host,
                                      db_port, autocommit=None):
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


    def check_database_connection(self, parameters=None):
        """Check if a database connection exists. If not, error out."""
        if not self.db_cursor:
            if parameters:
                self.establish_database_connection(parameters.db_database,
                                                   parameters.db_username,
                                                   parameters.db_password,
                                                   parameters.db_host,
                                                   parameters.db_port)
            else:
                display_message(121, "No database connection has been established.")


    def get_results(self):
        """Get the results of the last query."""
        results = []

        try:
            self.db_cursor.fetchall()
        except psycopg2.ProgrammingError:
            return None
        except Exception as e:
            display_message(122, f"Failed to get results: {e}.")

        if len(results) > 1:
            return results
        elif len(results) == 1:
            return results[0]
        else:
            return None


    def execute_sql_command(self, sql_command, commit=False, no_results=False):
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
            self.db_cursor.execute(sql.SQL(sql_command))

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
        """
        Read and execute an SQL script.

        Args:
            sql_file (str): Path to the SQL file.
            verbose (bool): Verbose output.
            parameters (SimpleNamespace, optional): Parameters to use to log in to the database.
        """
        self.check_database_connection(parameters)

        try:
            with open(sql_file, "r") as file:
                buffer = ""  # Store multi-line SQL statements

                for line in file:
                    line = line.strip()

                    # Skip empty lines and SQL comments
                    if not line or line.startswith("--"):
                        continue

                    buffer += line + " "  # Preserve spaces for readability

                    # If the SQL statement is complete (ends with a semicolon), execute it
                    if line.endswith(";"):
                        if verbose:
                            display_message(0, f"Executing SQL: {buffer.strip()}")

                        self.execute_sql_command(buffer.strip(), False, True)  # Execute full SQL command
                        buffer = ""  # Reset buffer for next query

            if buffer.strip():  # Catch any remaining statements that didn't end with ";"
                display_message(125, "Warning: Incomplete SQL command found.")
        except Exception as e:
            display_message(126, f"Can't process SQL file: {sql_file}. Error: {e}.")


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

        if not self.execute_sql_command(f"SELECT datname FROM pg_database WHERE datname = '{db_database}';"):
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
            with self.db_cursor as cur:
                cur.execute("""
                    SELECT EXISTS (
                        SELECT 1 FROM pg_tables 
                        WHERE tablename = %s AND schemaname = %s
                    );
                """, (table_name, schema))

                return cur.fetchone()[0]  # Returns True if table exists, False otherwise
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
        database = Database()

        database.process_sql_file(sql_file, verbose, parameters)
        database.close_database_connection()


    @staticmethod
    def load_sql_template(parameters, template_file, commit=False):
        """
        Read template replacing variables and execute an SQL script.

        Args:
            template_file (str): Path to the SQL file.
            parameters (dict | SimpleNamespace): Parameters to format into the SQL script.
            commit (bool): Commit changes after execution.
        """
        database = Database()

        database.process_sql_template(template_file, parameters, commit)
        database.close_database_connection()


    @staticmethod
    def safe_create_database(parameters, db_database, db_username):
        """
        Creates a PostgreSQL database if it does not exist.

        Args:
            parameters (SimpleNamespace): Parameters to use to log in to the database.
            db_database (str): Database name
            db_username (str): Database user
        """
        database = Database()

        database.create_database_unless_exists(db_database, db_username, parameters)
        database.close_database_connection()


    @staticmethod
    def does_table_exist(parameters, table_name, schema="public"):
        """
        Check to see if a table exists.
        Args:
            table_name (str): Name of the table.
            schema (str, optional): The schema of the table.
            parameters (SimpleNamespace): Parameters to use to log in to the database.
        Returns:
              bool: True if the table exists.
        """
        database = Database()
        result = database.table_exists(table_name, schema, parameters)

        database.close_database_connection()
        return result
