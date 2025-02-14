#!/usr/bin/env python3

import sys
import os
import shutil
import re
import subprocess

from pathlib import Path
from .database import Database
from .utilities import display_message, run_command, run_long_command, \
    user_home, append_to_file, change_ownership_recursive


def setup_rails(configuration):
    """
    Setup rails

    Args:
        configuration (SimpleNamespace): configuration to use.
    """
    username = configuration.owner
    rails_dir = configuration.install_directory
    sql_file = configuration.dump_file

    display_message(0, "Installing bundler...")
    run_command(f"cd {rails_dir} && gem install bundler -v \"~> 2.5\"", True, False, None, username)
    display_message(0, "Bundler installed.")
    display_message(0, "Installing gems...")
    run_long_command(f"cd {rails_dir} && bundle install", True, False, None, username)
    display_message(0, "Bundler installed.")

    if sql_file:
        display_message(0, f"Seeding the database from {sql_file}...")

        database = Database(configuration.db_database,
                            configuration.db_username,
                            configuration.db_password,
                            configuration.db_host,
                            configuration.db_port,
                            True)

        database.process_sql_file(sql_file, True)
        database.close_database_connection()
        display_message(0, "Database Seeded.")

    display_message(0, "Running database migrations...")
    run_command(f"cd {rails_dir} && set -a && . {configuration.env_file} && set +a && exec rails db:migrate",
                True, False, None, username)
    display_message(0, "Database migrations run.")

    if os.getenv("RAILS_ENV") == "production":
        display_message(0, "Precompiling assets for production...")
        run_command(f"cd {rails_dir} && bundle exec rails assets:precompile",
                    True, False, None, username)
        display_message(0, "Assets precompiled.")


def install_ruby(username):
    """
    Install Ruby 3.2.2.

    Args:
        username (str): The user to install ruby for.
    """
    home_dir = user_home(username)
    rubies_dir = f"{home_dir}/.rubies"
    install_dir = f"{rubies_dir}/ruby-3.2.2"
    path_string = f"PATH={install_dir}/bin:$PATH"
    ruby_path = shutil.which("ruby")
    ruby_installed = os.path.isdir(install_dir)

    if not ruby_installed and ruby_path:
        results = run_command(["ruby", "-v"], True, True)
        version_match = re.search(r"ruby (\d+)\.(\d+)\.(\d+)", results)

        if version_match:
            major, minor, patch = [int(version_match.group(1)), int(version_match.group(2)),
                                   int(version_match.group(3))]

            if (major >= 3) and (minor >= 2):
                ruby_installed = True

    if ruby_installed:
        display_message(0, ("Ruby >= 3.2 is already installed."
                            "if you want to replace it remove it first."))
        return

    display_message(0, "Installing Ruby 3.2.2...")
    display_message(0, "Getting required packages...")
    run_command("apt update", True, False)
    run_command("apt install -y curl build-essential libssl-dev libreadline-dev zlib1g-dev", True, False)
    display_message(0, "Installed required packages.")

    # Download and install ruby-install
    display_message(0, "Downloading and installing ruby-install...")
    run_command("curl -L https://github.com/postmodern/ruby-install/archive/refs/tags/v0.9.1.tar.gz | tar -xz",
                True, True)

    cwd = os.getcwd()
    ruby_install_dir = "ruby-install-0.9.1"

    os.chdir(ruby_install_dir)
    run_command("make install", True, True)
    os.chdir(cwd)
    shutil.rmtree(ruby_install_dir)
    display_message(0, "'ruby-install' installed.")

    # Install Ruby 3.2.2
    cwd = Path.cwd()

    os.chdir(home_dir)
    display_message(0, "Installing Ruby 3.2.2 from source (this will take a while)...")
    subprocess.run(["ruby-install", "-i", install_dir, "ruby", "3.2.2"], check=True)
    change_ownership_recursive(install_dir, username, username)
    display_message(0, "Ruby 3.2.2 installed.")

    # Set up environment variables
    if os.path.exists(".profile"):
        append_to_file(".profile", path_string)

    if os.path.exists(".bash_login"):
        append_to_file(".bash_login", path_string)

    if os.path.exists(".bashrc"):
        append_to_file(".bashrc", path_string)

    os.chdir(cwd)


def install_postgres(postgres_password):
    """
    Install PostgreSQL.

    Args:
        postgres_password (str): The password for the postgres user.
    """
    if os.path.exists("/etc/postgresql/15"):
        display_message(0, ("PostgreSQL is already installed. "
                            "if you want to replace it remove it first."))

        # Even if they have postgres already installed make sure that have the dev package for the pg gem
        run_command("apt update", True, False)
        run_command("apt install -y libpq-dev", True, False)
    else:
        display_message(0, "Installing PostgreSQL...")
        run_command("apt update", True, False)
        run_long_command("apt install -y postgresql postgresql-contrib libpq-dev", True, False)
        run_command("systemctl start postgresql", True, False)
        run_command("systemctl enable postgresql", True, False)
        display_message(0, "Installed PostgreSQL.")
        display_message(0, "Setting up Postgres user...")
        run_command(f"echo \"ALTER USER postgres WITH PASSWORD '{postgres_password}';\" | sudo -u postgres psql",
                    True, False)
        display_message(0, "Postgres user set up.")


def generate_certificate(install_directory, server_domain, owner, direct_install=False):
    """
    Generate and install a Let's Encrypt Certificate.

    Args:
        install_directory (str): The directory where the server is installed.
        server_domain (str): The domain the certificate is for.
        owner (str): The name of the user that owns the certificates.
        direct_install (bool, optional): Whether the certificate should be installed directly or put in secrets.
    """

    display_message(0, "Installing Let's Encrypt certificate...")

    if direct_install:
        secrets_dir = install_directory
    else:
        secrets_dir = f"{install_directory}/secrets"

    lets_encrypt_dir = f"/etc/letsencrypt/live/{server_domain}"
    lets_encrypt_cert_file = f"{lets_encrypt_dir}/fullchain.pem"
    lets_encrypt_key_file = f"{lets_encrypt_dir}/privkey.pem"
    cert_file = f"{secrets_dir}/ssl.crt"
    key_file = f"{secrets_dir}/ssl.key"

    if os.path.exists(cert_file):
        display_message(0, ("A certificate is already installed. "
                            "if you want to replace it remove it first."))
        return

    run_command("apt update")
    run_command("sudo apt install certbot -y")
    subprocess.run(["certbot",
                    "certonly",
                    "standalone",
                    "-d",
                    server_domain,
                    "-d",
                    f"www.{server_domain}"],
                   check=True,
                   stdin=sys.stdin)
    os.makedirs(secrets_dir, exist_ok=True)
    shutil.copy(lets_encrypt_cert_file, cert_file)
    shutil.copy(lets_encrypt_key_file, key_file)
    change_ownership_recursive(secrets_dir, owner, owner)
    display_message(0, "Let's Encrypt certificate installed.")
