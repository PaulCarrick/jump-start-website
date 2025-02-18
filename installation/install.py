#!/usr/bin/env python3

import argparse
import json
import os
import sys
import validators
import shutil

from pathlib import Path
from types import SimpleNamespace
from dotenv import load_dotenv
from configuration.debconf import DebConf
from configuration.database import Database
from configuration.rails_support import setup_rails, install_ruby, install_postgres, \
    generate_certificate, install_nginx, install_service
from configuration.utilities import display_message, run_command, present, \
    valid_integer, user_exists, directory_exists, valid_boolean_response, \
    generate_env, create_user, change_ownership_recursive, is_port_open


TEMPLATES = "./configuration/templates"
CONFIGURATION_FILE = "/etc/jump-start-website/config.json"


def main():
    args = parse_arguments()
    params = get_parameters(args)

    display_message(0, "Setting up  Jump Start Website...")

    if params.env_file and params.just_generate_env:
        variables = generate_variables(params)

        generate_env(params.env_file, variables)
    elif params.install_server:
        os.makedirs("/etc/jump-start-website", exist_ok=True)

        with open(CONFIGURATION_FILE, "w") as file:
            json.dump(vars(params), file, indent=4)

        install_server(params)
    elif params.update_server:
        os.makedirs("/etc/jump-start-website", exist_ok=True)

        with open(CONFIGURATION_FILE, "w") as file:
            json.dump(vars(params), file, indent=4)

        update_server(params)

    display_message(0, "Jump Start Website setup  successfully.")


def parse_arguments():
    """
    Parses command-line arguments.

    Returns:
        argparse.Namespace: The parsed arguments.
    """
    parser = argparse.ArgumentParser(description="Application configuration and installation script.")

    parser.add_argument("-c", "--install-certificate",
                        action="store_true", help="Generate a Let's Encrypt certificate.")
    parser.add_argument("-d", "--db-database",
                        help="Specify the name for the database.",
                        default=os.getenv("DB_DATABASE"))
    parser.add_argument("-D", "--domain",
                        help="Specify the domain name.",
                        default=os.getenv("SITE_DOMAIN"))
    parser.add_argument("-e", "--env-file",
                        help="Specify the name for the .env file.",
                        default=".env")
    parser.add_argument("-f", "--dump-file",
                        help="Specify the name for the dump file to install (optional)")
    parser.add_argument("-H", "--db-host",
                        help="Specify the hostname for the database.",
                        default=os.getenv("DB_HOST"))
    parser.add_argument("-g", "--install-postgres",
                        action="store_true", help="Install Postgres",
                        default=False)
    parser.add_argument("-i", "--installation-dir",
                        help="Specify the installation directory.")
    parser.add_argument("-I", "--install-service",
                        action="store_true", help="Install Service")
    parser.add_argument("-j", "--just-generate-env",
                        action="store_true", help="Only generate .env file.",
                        default=False)
    parser.add_argument("-l", "--local-port", type=int,
                        help="Specify the internal port for the server.",
                        default=os.getenv("INTERNAL_PORT"))
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
    parser.add_argument("-R", "--remove-install",
                        action="store_true", help="Remove installation files.")
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
    parser.add_argument("-x", "--install-nginx",
                        action="store_true", help="Install Nginx")

    args = parser.parse_args()

    if args.mode:
        args.mode = "http"

    return args


def get_parameters(args):
    """
    Get parameters from user input.

    Args:
        args (Namespace): The parsed arguments.

    Returns:
        SimpleNamespace: the parameters from user input.
    """
    params = SimpleNamespace()
    params.env_file = args.env_file
    params.just_generate_env = args.just_generate_env
    params.dump_file = args.dump_file

    # Initialize Debconf environment
    debconf = DebConf(TEMPLATES)

    debconf.initialize_debconf_environment()

    if os.path.exists(CONFIGURATION_FILE):
        with open(CONFIGURATION_FILE, "r") as file:
            params = json.load(file, object_hook=lambda d: SimpleNamespace(**d))

        reinstall = debconf.get_validated_input("jump-start-website/reinstall",
                                                lambda mode: mode in {"Yes", "No", "Quit", "Update"},
                                                "ERROR: You must confirm reinstallation.")

        if reinstall == "Update":
            params.update_server = True
            return params

        if reinstall != "Yes":
            display_message(11, "Installation aborted by user.")
            sys.exit(0)

    # Display the introduction
    debconf.show_debconf_message("jump-start-website/introduction", "")

    # Get server parameters
    params.mode = debconf.get_validated_input("jump-start-website/mode",
                                              lambda mode: mode in {"http", "https"},
                                              "ERROR: You must enter a valid mode (http or https).",
                                              args.mode,
                                              getattr(params, "mode", None))
    params.domain = debconf.get_validated_input("jump-start-website/domain",
                                                validators.domain,
                                                "ERROR: You must enter a domain name.",
                                                args.domain,
                                                getattr(params, "domain", None))
    params.hostname = debconf.get_validated_input("jump-start-website/hostname",
                                                  validators.hostname,
                                                  "ERROR: You must enter a server name.",
                                                  args.hostname,
                                                  getattr(params, "hostname", params.domain))
    params.url = debconf.get_validated_input("jump-start-website/url",
                                             validators.url,
                                             "ERROR: You must enter a valid URL.",
                                             args.url,
                                             getattr(params, "url", f"{params.mode}://{params.hostname}"))
    params.host = debconf.get_validated_input("jump-start-website/host",
                                              validators.hostname,
                                              "ERROR: You must enter a server name.",
                                              args.host,
                                              getattr(params, "host", None))

    if getattr(params, "port", None):
        default_port = str(params.port)
    elif args.port:
        default_port = str(args.port)
    else:
        default_port = "3000"

    params.port = int(debconf.get_validated_input("jump-start-website/port",
                                                  valid_integer,
                                                  "ERROR: You must enter a valid port number.",
                                                  None,
                                                  default_port))

    if getattr(params, "local_port", None):
        default_port = str(params.local_port)
    elif args.port:
        default_port = str(args.local_port)
    else:
        default_port = "3000"

    params.local_port = int(debconf.get_validated_input("jump-start-website/local-port",
                                                        valid_integer,
                                                        "ERROR: You must enter a valid port number.",
                                                        None,
                                                        default_port))

    # Get database details
    params.db_host = debconf.get_validated_input("jump-start-website/db-host",
                                                 validators.hostname,
                                                 "ERROR: You must enter a database host.",
                                                 args.db_host,
                                                 getattr(params, "db_host", None))

    if getattr(params, "db_port", None):
        default_port = str(params.db_port)
    elif args.db_port:
        default_port = str(args.db_port)
    else:
        default_port = "5432"

    params.db_port = int(debconf.get_validated_input("jump-start-website/db-port",
                                                     valid_integer,
                                                     "ERROR: You must enter a database port.",
                                                     None,
                                                     default_port))
    params.db_database = debconf.get_validated_input("jump-start-website/db-name",
                                                     present,
                                                     "ERROR: You must enter a database name.",
                                                     args.db_database,
                                                     getattr(params, "db_database", None))
    params.db_username = debconf.get_validated_input("jump-start-website/db-user",
                                                     present,
                                                     "ERROR: You must enter a database user.",
                                                     args.db_username,
                                                     getattr(params, "db_username", None))
    params.db_password = debconf.get_validated_input("jump-start-website/db-password",
                                                     present,
                                                     "ERROR: You must enter a database password.",
                                                     args.db_password,
                                                     getattr(params, "db_password", None))
    params.postgres_password = debconf.get_validated_input("jump-start-website/postgres-password",
                                                           present,
                                                           "ERROR: You must enter a postgres user password.",
                                                           args.db_password,
                                                           getattr(params, "db_password", params.db_password))

    # Installation information
    params.owner = debconf.get_validated_input("jump-start-website/owner",
                                               present,
                                               "ERROR: You must enter a valid owner.",
                                               args.owner,
                                               getattr(params, "owner", None))
    params.owner_password = debconf.get_validated_input("jump-start-website/owner-password",
                                                        present,
                                                        "ERROR: You must enter a valid owner password.",
                                                        args.owner_password,
                                                        getattr(params, "owner_password", None))

    if user_exists(params.owner):
        home_dir = run_command(f"eval echo ~{params.owner}", capture_output=True)
        home_dir = home_dir.strip()
        default_install_dir = f"{home_dir}/jump-start-website"
        level = 1
    else:
        level = 2
        default_install_dir = f"/home/{params.owner}/jump-start-website"

    params.install_directory = debconf.get_validated_input("jump-start-website/install-dir",
                                                           lambda directory: directory_exists(directory, level),
                                                           "ERROR: You must enter a valid install directory.",
                                                           args.installation_dir,
                                                           getattr(params,
                                                                   "install_directory",
                                                                   default_install_dir))

    if not args.no_install:
        params.install_postgres = debconf.get_validated_input("jump-start-website/install-postgres",
                                                              valid_boolean_response,
                                                              "ERROR: Invalid choice. Select Yes or No.",
                                                              args.install_postgres,
                                                              getattr(params, "install_postgres", None))
        params.install_ruby = debconf.get_validated_input("jump-start-website/install-ruby",
                                                          valid_boolean_response,
                                                          "ERROR: Invalid choice. Select Yes or No.",
                                                          args.install_ruby,
                                                          getattr(params, "install_ruby", None))
        params.install_certificate = debconf.get_validated_input("jump-start-website/install-certificate",
                                                                 valid_boolean_response,
                                                                 "ERROR: Invalid choice. Select Yes or No.",
                                                                 args.install_certificate,
                                                                 getattr(params, "install_certificate", None))
        params.install_nginx = debconf.get_validated_input("jump-start-website/install-nginx",
                                                           valid_boolean_response,
                                                           "ERROR: Invalid choice. Select Yes or No.",
                                                           args.install_nginx,
                                                           getattr(params, "install_nginx", None))
        params.install_service = debconf.get_validated_input("jump-start-website/install-service",
                                                             valid_boolean_response,
                                                             "ERROR: Invalid choice. Select Yes or No.",
                                                             args.install_service,
                                                             getattr(params, "install_service", None))
        params.remove_install = debconf.get_validated_input("jump-start-website/remove-install",
                                                            valid_boolean_response,
                                                            "ERROR: You must confirm removal.",
                                                            args.remove_install,
                                                            getattr(params, "remove_install", None))
        params.confirm_install = debconf.get_validated_input("jump-start-website/confirm-install",
                                                             valid_boolean_response,
                                                             "ERROR: You must confirm installation.",
                                                             None,
                                                             getattr(params, "confirm_install", None))
        params.install_server = (params.confirm_install == "Yes")

        if params.confirm_install != "Yes":
            display_message(11, "Installation aborted by user.")
            sys.exit(0)
    else:
        params.install_server = False

    return params


def update_server(params):
    """
    Update the server code but don't reinstall it.

    Args:
        params (SimpleNamespace): The previous parameters for the server.
    """
    display_message(0, "Updating Jump Start Website...")
    package_dir = None
    install_directory = params.install_directory
    install_path = Path(install_directory)

    # Ensure the installation directory exists
    if not os.path.exists(install_directory):
        display_message(19, "Installation directory does not exist!")

    current_path = Path(os.path.abspath(__file__))

    try:
        package_dir = next(p for p in current_path.parents if p.name == "jump-start-website")
    except StopIteration:
        display_message(21, "Code directory not found")

    if not os.path.exists(package_dir):
        display_message(19, "Error: Package directory not found.")

    package_path = Path(package_dir)

    if package_path.resolve() == install_path.resolve():
        display_message(20, "You cannot install into the package directory.")

    # Copy files to install directory
    shutil.copytree(package_dir, install_directory, dirs_exist_ok=True)
    os.chdir(install_directory)
    change_ownership_recursive(install_directory, params.owner, params.owner)
    setup_rails(params)

    if params.remove_install:
        shutil.rmtree(package_dir)

    display_message(0, "Jump Start Website Updated.")


def install_server(params):
    """
    Install the Server

    Args:
        params (SimpleNamespace): The parameters to use to configure the server.
    """
    display_message(0, "Installing Jump Start Website...")
    package_dir = None
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

    gem_dir = f"{install_directory}/gems"

    if not os.path.isdir(gem_dir):
        os.makedirs(gem_dir)

    if params.install_postgres.upper() == "YES":
        install_postgres(params.postgres_password)

    setup_database(params)

    if params.install_ruby.upper() == "YES":
        install_ruby(params.owner)

    current_path = Path(os.path.abspath(__file__))

    try:
        package_dir = next(p for p in current_path.parents if p.name == "jump-start-website")
    except StopIteration:
        display_message(21, "Code directory not found")

    if not os.path.exists(package_dir):
        display_message(19, "Error: Package directory not found.")

    package_path = Path(package_dir)

    if package_path.resolve() == install_path.resolve():
        display_message(20, "You cannot install into the package directory.")

    # Copy files to install directory
    shutil.copytree(package_dir, install_directory, dirs_exist_ok=True)
    os.chdir(install_directory)

    variables = generate_variables(params)

    generate_env(params.env_file, variables)
    load_dotenv()

    if not Database.is_table_populated(params, 'sections'):
        Database.empty_database(params, params.db_database)
        Database.load_sql_file(params,
                               f"{install_directory}/installation/dump.sql",
                               True)

    change_ownership_recursive(install_directory, owner, owner)
    setup_rails(params)

    if params.install_certificate.upper() == "YES":
        generate_certificate(params.install_directory, params.domain, params.owner)

    if params.install_nginx.upper() == "YES":
        install_nginx(params)

    if params.install_service.upper() == "YES":
        install_service(params)

    if params.install_service.upper() == "YES":
        run_command("systemctl start jumpstartwebsite.service", True, False)
        run_command("systemctl enable jumpstartwebsite.service", True, False)

    if params.remove_install:
        shutil.rmtree(package_dir)

    display_message(0, "Jump Start Website Installed.")


def setup_database(params):
    database = Database("postgres", "postgres",
                        params.postgres_password, params.db_host,
                        params.db_port)

    database.process_sql_template(f"{get_setup_directory()}/create_database_user.sql", params, True)
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
            "internal_port":            params.local_port,
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
            "rails_directory":          params.install_directory,
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


def get_setup_directory():
    return Path(__file__).resolve().parent


if __name__ == "__main__":
    main()
