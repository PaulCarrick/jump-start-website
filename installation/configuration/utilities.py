#!/usr/bin/env python3

# Utility functions

import grp
import itertools
import os
import pwd
import shlex
import socket
import subprocess
import sys
import threading
from pathlib import Path
from types import SimpleNamespace

# ANSI color codes for terminal messages
GREEN = "\033[32m"
ORANGE = "\033[38;5;214m"
RED = "\033[31m"
RESET = "\033[0m"

display_output = True
throw_error = False


def no_output():
    global display_output
    display_output = False


def raise_errors():
    global throw_error
    throw_error = True


def display_message(error_level, message):
    """
    Displays a message to the console with a given error level
     and optionally exit with a non-zero exit code if the error level
     is above 19.

    Args:
        error_level (int): The amount to increment the current_error_level.
        message (str): The message to display.

    error_level contains the current error level.
     If error level is negative then raise an error rather than exiting (use abs of error level).
     display_message considers any error level above 19 as a fatal error.
     It subtracts 19 so that the error exit starts at 1.
     0-9 is not an error and displays in green.
     10-19 is a warning and displays in orange.
     > 19 is an error and display in red  then exits with an exit code
     of error_level - 19 (starts at 1 for 20).
    """
    if error_level < 0 or throw_error:
        error_level = abs(error_level)
        raise_error = True
    else:
        raise_error = False

    if error_level < 10:
        if display_output:
            print(f"{GREEN}{message}{RESET}")
    elif error_level < 20:
        if display_output:
            print(f"{ORANGE}{message}{RESET}")
    else:
        if display_output:
            print(f"{RED}{message}{RESET}", file=sys.stderr)

        if raise_error:
            raise Exception(message)
        else:
            sys.exit(error_level - 19)


def run_command(
    command, flag_error=True, capture_output=True, timeout=None, as_user=None
):
    """Run argv directly, or a shell expression when supplied as a string.

    Preserve the installer API: captured output on success, otherwise a boolean.
    A failed optional command returns an empty string or False.
    """
    use_shell = isinstance(command, str)
    command_args = command if use_shell else list(command)
    if as_user:
        shell_command = command if use_shell else shlex.join(command_args)
        command_args = ["su", "-", as_user, "-c", shell_command]
        use_shell = False
    try:
        result = subprocess.run(
            command_args,
            timeout=timeout,
            shell=use_shell,
            capture_output=True,
            text=True,
            env=os.environ,
        )
    except subprocess.TimeoutExpired:
        return "" if capture_output else False
    except OSError as error:
        if flag_error:
            display_message(90, f"Unable to start command: {error}")
        return "" if capture_output else False
    if result.returncode:
        if flag_error:
            display_message(
                89,
                f"Command failed with exit code {result.returncode}: {result.stderr.strip()}",
            )
        return "" if capture_output else False
    return result.stdout if capture_output else True


def run_long_command(
    command, flag_error=True, capture_output=True, timeout=None, as_user=None
):
    """Run a command with a spinner that always stops, including on failure."""
    stop_event = threading.Event()
    spinner_thread = threading.Thread(target=spinner, args=(stop_event,), daemon=True)
    spinner_thread.start()
    try:
        return run_command(command, flag_error, capture_output, timeout, as_user)
    finally:
        stop_event.set()
        spinner_thread.join()
        sys.stdout.write("\n")


def spinner(stop_event):
    """
    Display a spinner on the command line.

    Args:
        stop_event (StopEvent): The event to stop the spinner.
    """
    spinner_symbols = itertools.cycle(["-", "\\", "|", "/"])

    while not stop_event.is_set():  # Run until stop_event is set
        sys.stdout.write(next(spinner_symbols))
        sys.stdout.flush()
        stop_event.wait(0.5)
        sys.stdout.write("\b")

    sys.stdout.write("\b")
    sys.stdout.flush()


def user_exists(username):
    """
    Check if a user exists in the system.

    Args:
        username (str): The username to check.

    Returns:
        bool: True if the user exists in the system.
    """
    return bool(run_command(["id", username], flag_error=False))


def directory_exists(path, level=0):
    """
    Check if a directory exists in the system.

    Args:
        path (str): The path to check.
        level(int=0): If greater than zero check "level" levels up.

    Returns:
        bool: True if the directory exists in the system.
    """
    check_path = Path(path)

    if level > 0:
        for i in range(level + 1):
            check_path = check_path.parent

    return check_path.exists()


def user_home(username):
    return os.path.expanduser(f"~{username}")


def present(value):
    """
    Check if a value is present and populated.

    Args:
        value (str): The variable to check.
    Returns:
        bool: True if the value is present.
    """
    return value is not None and str(value).strip() != ""


def valid_integer(value):
    """
    Check if a value is present and is a string containing an integer.

    Args:
        value (str): The string to check.
    Returns:
        bool: True if the string contains a valid integer.
    """
    return isinstance(value, str) and value.isdigit()


def valid_boolean_response(response):
    """
    Check if a value is present and is a string containing Yes, No or Quit.

    Args:
        response (str): The string to check.
    Returns:
        bool: True if the string contains a valid response.
    """
    return response in ["Yes", "No", "Quit"]


def generate_env(env_filename, variables):
    """
    Generate an .env file.

    Args:
        env_filename (str): The name of the .env file.
        variables (dict): The variables to write to the file.
    """
    try:
        with open(env_filename, "w") as file:
            for key, value in variables.items():
                file.write(f'{key.upper()}="{value}"\n')
    except Exception as e:
        display_message(91, f"Cannot write {env_filename}: {str(e)}.")


def create_user(username, password):
    """
    Create a user in the system and assign a password to the user.

    Args:
        username (str): The username to create.
        password (str): The password for thw user.
    Returns:
        None
    """
    display_message(0, f"Setting up user: {username}...")

    if not run_command(f"useradd -m -s /bin/bash {username}", True, False):
        display_message(92, f"Cannot create user: {username}...")

    try:
        display_message(0, f"Setting password for user: {username}...")

        process = subprocess.Popen(
            ["sudo", "chpasswd"], stdin=subprocess.PIPE, text=True
        )
        process.communicate(input=f"{username}:{password}")

        if process.returncode == 0:
            display_message(0, f"Password successfully set for user: {username}.")
        else:
            display_message(93, f"Failed to set password for user: {username}.")
    except subprocess.SubprocessError as e:
        display_message(94, f"Error setting password for {username}: {e}")

    display_message(0, f"User: {username} setup complete.")


def process_template(filename, params):
    """
    Read, and replace values in a template file.

    Args:
        filename (str): Path to the template file.
        params (dict | SimpleNamespace): Parameters to format into the template.

    Returns:
        str: The results of the replacement.
    """
    if isinstance(params, SimpleNamespace):
        params = vars(params)

    try:
        with open(filename, "r") as file:
            results = file.read().format(**params)  # Format entire script
    except Exception as e:
        display_message(95, f"Can't process template file {filename}. Error: {e}")

    return results


def change_ownership_recursive(path, user, group):
    """
    Recursively change owner and group of a directory and its contents.
    Args:
        path (str): Path to the directory to change.
        user (str): The owner of the directory to change.
        group (str): The group of the directory to change.
    """
    display_message(0, f"Recursively changing owner to {user} for {path}...")

    # Get user and group IDs
    uid = pwd.getpwnam(user).pw_uid
    gid = grp.getgrnam(group).gr_gid

    # Change ownership of the root directory
    os.chown(path, uid, gid)

    # Walk through all files and subdirectories
    for root, dirs, files in os.walk(path):
        for d in dirs:
            os.chown(os.path.join(root, d), uid, gid)
        for f in files:
            os.chown(os.path.join(root, f), uid, gid)

    display_message(0, f"Recursively changed owner to {user} for {path}.")


def append_to_file(filename, lines):
    """
    Append text to a text file
    Args:
        filename (str): Path to the file to append to
        lines (str|list): The ext to append.
    """
    with open(filename, "a") as file:
        if isinstance(lines, list):
            for line in lines:
                file.write(f"{line}\n")
        else:
            file.write(f"{lines}\n")


def replace_values_in_file(filename, values):
    """
    Read, and replace values in a file.

    Args:
        filename (str): Path to the file.
        values (dict | SimpleNamespace | array of dicts): values to replace in the file.

    Returns:
        None
    """
    try:
        if isinstance(values, dict):
            iterator = values.items()
        elif isinstance(values, SimpleNamespace):
            iterator = vars(values).items()
        else:
            iterator = list(values)

        with open(filename, "r") as file:
            lines = file.readlines()

        results = []

        for line in lines:
            for key, value in iterator:
                line = line.replace(key, value)

            results.append(line)

        with open(filename, "w") as file:
            for line in results:
                file.write(line)
    except Exception as e:
        display_message(96, f"Can't process file {filename}. Error: {e}")


def is_port_open(host, port, timeout=3):
    """
    Check to see if a port is open.

    Args:
        host (str): The host to check.
        port: (int) The port to check.
        timeout: (int=3) The timeout in seconds.
    Returns:
        True if the port is open, False otherwise.
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(timeout)  # Timeout to avoid long waits
        result = s.connect_ex((host, port))
        return result == 0  # Returns True if the port is open, False otherwise
