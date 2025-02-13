#!/usr/bin/env python3

import argparse
import os
import sys
import validators
import getpass
import shutil

from pathlib import Path
from types import SimpleNamespace
from dotenv import load_dotenv
from configuration.debconf import DebConf
from configuration.database import Database
from configuration.utilities import display_message, run_command, present, \
    valid_integer, user_exists, directory_exists, valid_boolean_response, \
    generate_env, create_user, run_long_command, change_ownership_recursive


TEMPLATES = "./configuration/templates"


def install_server(params):
    """
    Install the Server

    Args:
        params (SimpleNamespace): The parameters to use to configure the server.
    """
    display_message(0, "Installing Jumpstart Server...")
    owner = params.owner

    # Ensure the owner exists
    if not user_exists(owner):
        create_user(owner, params.owner_password)

    install_directory = params.install_directory
    install_path = Path(install_directory)

    # Ensure the installation directory exists
    if not os.path.exists(install_directory):
        display_message(0, f"Creating installation directory: {install_directory}")
        os.makedirs(install_directory)

    os.makedirs(f"{install_directory}/gems")

    if params.install_postgres.upper() == "YES":
        install_postgres(params)

    setup_database(params)

    if params.install_ruby.upper() == "YES":
        install_ruby()

    package_dir = run_command("dpkg-query -L jump-start-website | grep -E '^/usr/share/' | head -n 1",
                              capture_output=True)

    if not package_dir:
        package_dir = Path.cwd()

    if not os.path.exists(package_dir):
        display_message(19, "Error: Package directory not found.")

    package_path = Path(package_dir)

    if package_path.resolve() == install_path.resolve():
        display_message(20, "You cannot install into the package directory.")

    # Copy files to install directory
    shutil.copytree(package_dir, install_directory)
    os.chdir(install_directory)

    variables = generate_variables(params)

    generate_env(".env", variables)
    load_dotenv()

    change_ownership_recursive(install_directory, params.username, params.username)
    setup_rails(params)
    display_message(0, "Jumpstart Server Installed.")

def setup_rails(params):
    """
    Setup rails

    Args:
        params (SimpleNamespace): The parameters to use to configure the server.
    """
    display_message(0, "Installing bundler...")
    run_command("install bundler -v '~> 2.5'", True, False, params.username)
    display_message(0, "Bundler installed.")
    display_message(0, "Installing gems...")
    run_command("bundle install", True, False, params.username)
    display_message(0, "Bundler installed.")
    display_message(0, "Running database migrations...")
    run_command("exec rails db:migrate", True, False, params.username)
    display_message(0, "Database migrations run.")

    if os.getenv("RAILS_ENV") == "production":
        display_message(0, "Precompiling assets for production...")
        run_command("bundle exec rails assets:precompile", True, False, params.username)
        display_message(0, "Assets precompiled.")

def install_ruby():
    """
    Install Ruby 3.2.2.
    """
    display_message(0, "Installing Ruby 3.2.2...")
    display_message(0, "Getting required packages...")
    run_command("apt-get update", True, False)
    run_command("apt-get install -y curl build-essential libssl-dev libreadline-dev zlib1g-dev", True, False)
    display_message(0, "Installed required packages.")

    # Download and install ruby-install
    display_message(0, "Downloading and installing ruby-install...")
    run_command("curl -L https://github.com/postmodern/ruby-install/archive/refs/tags/v0.9.1.tar.gz | tar -xz", True,
                False)
    run_command("cd ruby-install-0.9.1 && make install && cd .. && rm -rf ruby-install-0.9.1", True, False)
    display_message(0, "'ruby-install' installed.")

    # Install Ruby 3.2.2
    display_message(0, "Installing Ruby 3.2.2 from source...")
    run_long_command("ruby-install ruby 3.2.2", True, False)
    display_message(0, "Ruby 3.2.2 from installed.")

    # Set up environment variables
    run_command("echo 'export PATH=\"$HOME/.rubies/ruby-3.2.2/bin:$PATH\"' >> /etc/profile.d/ruby.sh", True, False)
    run_command(". /etc/profile.d/ruby.sh", True, False)


def install_postgres(params):
    postgres_path = shutil.which("postgres")

    if postgres_path:
        display_message(0, ("PostgreSQL is already installed."
                            "if you want to replace it remove it first."))
    else:
        display_message(0, "Installing PostgreSQL...")
        run_command("apt-get update", True, False)
        run_long_command("apt install -y postgresql postgresql-contrib", True, False)
        run_command("systemctl start postgresql", True, False)
        run_command("systemctl enable postgresql", True, False)
        display_message(0, "Installed PostgreSQL.")
        display_message(0, "Setting up Postgres user...")
        run_command(f"echo \"ALTER USER postgres WITH PASSWORD '{params.postgres_password}';\" | sudo -u postgres psql",
                    True, False)
        display_message(0, "Postgres user set up.")


def setup_database(params):
    database = Database("postgres", "postgres",
                        params.postgres_password, params.db_host,
                        params.db_port)

    database.process_sql_template("./create_database_user", params, True)
    database.create_database_unless_exists(params.db_database, params.db_username)
    database.close_database_connection()


def generate_variables(params):
    """
    Setup environmental variables.

    Args:
        params (SimpleNamespace): The parameters to use to configure the server.
    """
    results = {}

    results.update({
            "startup":                  "true",
            "dockerized":               "false",
            "project_name":             "jump_start_server",
            "site_domain":              params.domain,
            "site_host":                params.hostname,
            "site_url":                 params.url,
            "server_host":              params.host,
            "server_mode":              params.mode,
            "server_port":              params.port,
            "internal_port":            params.port,
            "external_port":            params.port,
            "guest_user":               "Guest User",
            "username":                 params.owner,
            "user_password":            params.owner_password,
            "db_host":                  params.db_host,
            "db_port":                  params.db_port,
            "db_database":              params.db_database,
            "db_username":              params.db_username,
            "db_password":              params.db_password,
            "postgres_password":        params.postgres_password,
            "pggssencmode":             "disable",
            "db_url":                   f"postgres://{params.db_username}:{params.db_password}@{params.db_host}:{params.db_port}/{params.db_database}",
            "rack_env":                 "production",
            "rails_env":                "production",
            "rails_master_key":         "31c4d6937460cb67802017edd2016b94",
            "rails_serve_static_files": "enabled",
            "gem_home":                 f"{params.install_directory}/gems",
            "recaptcha_enabled":        "false",
            "recaptcha_site_key":       "",
            "recaptcha_secret_key":     "",
            "sudo_available":           "false",
            "ssh_port":                 "",
            "ssh_public_key":           "",
            "lang":                     "en_US.UTF - 8",
            "language":                 "en_US.UTF - 8"
    })

    return results


def parse_arguments():
    """
    Parses command-line arguments.

    Returns:
        argparse.Namespace: The parsed arguments.
    """
    parser = argparse.ArgumentParser(description="Application configuration and installation script.")

    parser.add_argument("-d", "--db-database",
                        help="Specify the name for the database.",
                        default=os.getenv("DB_DATABASE"))
    parser.add_argument("-D", "--domain",
                        help="Specify the domain name.",
                        default=os.getenv("SITE_DOMAIN"))
    parser.add_argument("-H", "--db-host",
                        help="Specify the hostname for the database.",
                        default=os.getenv("DB_HOST"))
    parser.add_argument("-g", "--install-postgres",
                        action="store_true", help="Install Postgres",
                        default=False)
    parser.add_argument("-i", "--installation-dir",
                        help="Specify the installation directory.")
    parser.add_argument("-m", "--mode", action="store_true",
                        help="Use HTTP for server",
                        default=os.getenv("SERVER_MODE") == "http")
    parser.add_argument("-n", "--hostname",
                        help="Specify the hostname for the site.",
                        default=os.getenv("SITE_HOST"))
    parser.add_argument("-N", "--no-install",
                        action="store_true", help="Do not install, only configure.",
                        default=None)
    parser.add_argument("-o", "--owner",
                        help="Specify the owner for the installation.",
                        default=os.getenv("USERNAME"))
    parser.add_argument("-O", "--db-port", type=int,
                        help="Specify the port for the database.",
                        default=os.getenv("DB_PORT"))
    parser.add_argument("-p", "--db-password",
                        help="Specify the database password.",
                        default=os.getenv("DB_PASSWORD"))
    parser.add_argument("-t", "--postgres-password",
                        help="Specify the postgres user password.",
                        default=os.getenv("DB_PASSWORD"))
    parser.add_argument("-P", "--port", type=int,
                        help="Specify the port for the server.",
                        default=os.getenv("SERVER_PORT"))
    parser.add_argument("-r", "--install-ruby",
                        action="store_true", help="Install Ruby 3.2",
                        default=False)
    parser.add_argument("-s", "--host",
                        help="Specify the local hostname of the server.",
                        default=os.getenv("SERVER_HOST"))
    parser.add_argument("-u", "--db-username",
                        help="Specify the database username.",
                        default=os.getenv("DB_USERNAME"))
    parser.add_argument("-U", "--url",
                        help="Specify the URL for the server.",
                        default=os.getenv("SITE_URL"))
    parser.add_argument("-w", "--owner-password",
                        help="Specify the owner password for the installation.",
                        default=os.getenv("USER_PASSWORD"))

    args = parser.parse_args()

    return args


def get_parameters(args):
    """
    Get parameters from user input.

    Returns:
        SimpleNamespace: the parameters from user input.
    """
    result = {}

    # Initialize Debconf environment
    debconf = DebConf(TEMPLATES)

    debconf.initialize_debconf_environment()

    # Display the introduction
    debconf.show_debconf_message("jump-start-website/introduction", "")

    # Get server parameters
    mode = "http" if args.mode else debconf.get_validated_input("jump-start-website/mode",
                                                                present,
                                                                "ERROR: You must enter a valid mode (http or https)."
                                                                )

    domain = args.domain or debconf.get_validated_input(
            "jump-start-website/domain", validators.domain,
            "ERROR: You must enter a domain name."
    )

    debconf.set_debconf_value("jump-start-website/hostname", domain)
    hostname = args.hostname or debconf.get_validated_input(
            "jump-start-website/hostname", validators.hostname,
            "ERROR: You must enter a server name."
    )

    debconf.set_debconf_value("jump-start-website/url", f"{mode}://{hostname}")
    url = args.url or debconf.get_validated_input(
            "jump-start-website/url", validators.url,
            "ERROR: You must enter a valid URL."
    )

    host = args.host or debconf.get_validated_input(
            "jump-start-website/host", validators.hostname,
            "ERROR: You must enter a server name."
    )

    port = int(args.port or debconf.get_validated_input(
            "jump-start-website/port", valid_integer,
            "ERROR: You must enter a valid port number."
    ))

    # Get database details
    db_host = args.db_host or debconf.get_validated_input(
            "jump-start-website/db-host", validators.hostname,
            "ERROR: You must enter a database host."
    )

    db_port = int(args.db_port or debconf.get_validated_input(
            "jump-start-website/db-port", valid_integer,
            "ERROR: You must enter a database port."
    ))

    db_database = args.db_database or debconf.get_validated_input(
            "jump-start-website/db-name", present,
            "ERROR: You must enter a database name."
    )

    db_username = args.db_username or debconf.get_validated_input(
            "jump-start-website/db-user", present,
            "ERROR: You must enter a database user."
    )

    db_password = args.db_password or debconf.get_validated_input(
            "jump-start-website/db-password", present,
            "ERROR: You must enter a database password."
    )

    debconf.set_debconf_value("jump-start-website/postgres-password", db_password)

    postgres_password = args.postgres_password or debconf.get_validated_input(
            "jump-start-website/postgres-password", present,
            "ERROR: You must enter a postgres user password."
    )

    # Installation information
    owner = args.owner or debconf.get_validated_input(
            "jump-start-website/owner", present,
            "ERROR: You must enter a valid owner."
    )

    owner_password = args.owner_password or debconf.get_validated_input(
            "jump-start-website/owner-password", present,
            "ERROR: You must enter a valid owner password."
    )

    if user_exists(owner):
        home_dir = run_command(f"eval echo ~{owner}", capture_output=True)
        home_dir = home_dir.strip()
        default_install_dir = f"{home_dir}/rails"
        debconf.set_debconf_value("jump-start-website/install-dir", default_install_dir)

        install_directory = args.installation_dir or debconf.get_validated_input(
                "jump-start-website/install-dir", directory_exists,
                "ERROR: You must enter a valid install directory."
        )
    else:
        debconf.set_debconf_value("jump-start-website/install-dir", f"/home/{owner}/rails")

        install_directory = args.installation_dir or debconf.get_validated_input(
                "jump-start-website/install-dir", present,
                "ERROR: You must enter a valid install directory."
        )

    if not args.no_install:
        postgres = args.install_postgres or debconf.get_validated_input(
                "jump-start-website/install-postgres", valid_boolean_response,
                "ERROR: Invalid choice. Select Yes or No."
        )

        ruby = args.install_ruby or debconf.get_validated_input(
                "jump-start-website/install-ruby", valid_boolean_response,
                "ERROR: Invalid choice. Select Yes or No."
        )

        confirm_install = debconf.get_validated_input(
                "jump-start-website/confirm-install", valid_boolean_response,
                "ERROR: You must confirm installation."
        )

        if confirm_install != "Yes":
            display_message(11, "Installation aborted by user.")
            sys.exit(0)

        result.update({
                "mode":              mode,
                "domain":            domain,
                "hostname":          hostname,
                "url":               url,
                "host":              host,
                "port":              port,
                "db_host":           db_host,
                "db_port":           db_port,
                "db_database":       db_database,
                "db_username":       db_username,
                "postgres_password": postgres_password,
                "db_password":       db_password,
                "install_server":    True,
                "owner":             owner,
                "owner_password":    owner_password,
                "install_directory": install_directory,
                "install_ruby":      ruby,
                "install_postgres":  postgres
        })
    else:
        result.update({
                "mode":              mode,
                "domain":            domain,
                "hostname":          hostname,
                "url":               url,
                "host":              host,
                "port":              port,
                "db_host":           db_host,
                "db_port":           db_port,
                "db_database":       db_database,
                "db_username":       db_username,
                "postgres_password": postgres_password,
                "db_password":       db_password,
                "owner":             owner,
                "owner_password":    owner_password,
                "install_directory": install_directory,
                "install_server":    False
        })

    return SimpleNamespace(**result)


def main():
    args = parse_arguments()
    params = get_parameters(args)

    display_message(0, "Setting up  Jump Start Server...")

    if params.install_server:
        install_server(params)

    if params.owner != getpass.getuser():
        run_command(
                f"su {params.owner} -c \"bin/setup_ruby.rb {params.db_host} {params.db_port} {params.db_database} {params.db_username} {params.db_password}\"")
    else:
        run_command(
                f"bin/setup_ruby.rb {params.db_host} {params.db_port} {params.db_database} {params.db_username} {params.db_password}\"")

    display_message(0, "Jump Start Server setup  successfully.")


if __name__ == "__main__":
    main()
