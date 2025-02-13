#!/usr/bin/env python3

import os
import shutil
import re
import subprocess

from pathlib import Path

from .utilities import display_message, run_command, run_long_command, \
    user_home, append_to_file, change_ownership_recursive


def setup_rails(username):
    """
    Setup rails

    Args:
        username (str): The user to set up rails for
    """
    display_message(0, "Installing bundler...")
    run_command("gem install bundler -v \"~> 2.5\"", True, False, None, username)
    display_message(0, "Bundler installed.")
    display_message(0, "Installing gems...")
    run_command("bundle install", True, False, None, username)
    display_message(0, "Bundler installed.")
    display_message(0, "Running database migrations...")
    run_command("exec rails db:migrate", True, False, None, username)
    display_message(0, "Database migrations run.")

    if os.getenv("RAILS_ENV") == "production":
        display_message(0, "Precompiling assets for production...")
        run_command("bundle exec rails assets:precompile", True, False, None, username)
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
    ruby_installed =  os.path.isdir(install_dir)

    if not ruby_installed and ruby_path:
        results = run_command(["ruby", "-v"], True, True)
        version_match = re.search(r"ruby (\d+)\.(\d+)\.(\d+)", results)

        if version_match:
            major, minor, patch = [int(version_match.group(1)), int(version_match.group(2)),
                                   int(version_match.group(3))]

            if (major >= 3) and (minor >= 2):
                rbuy_installed = True

    if ruby_installed:
        display_message(0, ("Ruby >= 3.2 is already installed."
                            "if you want to replace it remove it first."))
        return

    display_message(0, "Installing Ruby 3.2.2...")
    display_message(0, "Getting required packages...")
    run_command("apt-get update", True, False)
    run_command("apt-get install -y curl build-essential libssl-dev libreadline-dev zlib1g-dev", True, False)
    display_message(0, "Installed required packages.")

    # Download and install ruby-install
    display_message(0, "Downloading and installing ruby-install...")
    run_command("curl -L https://github.com/postmodern/ruby-install/archive/refs/tags/v0.9.1.tar.gz | tar -xz",
                True,True)

    cwd = os.getcwd()
    ruby_install_dir="ruby-install-0.9.1"

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
        run_command(f"echo \"ALTER USER postgres WITH PASSWORD '{postgres_password}';\" | sudo -u postgres psql",
                    True, False)
        display_message(0, "Postgres user set up.")
