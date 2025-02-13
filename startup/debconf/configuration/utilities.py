#!/usr/bin/env python3

# Utility functions

import sys
import os
import pwd
import grp
import subprocess
import time
import threading
import itertools
import shlex
from pathlib import Path
from types import SimpleNamespace


# ANSI color codes for terminal messages
GREEN = "\033[32m"
ORANGE = "\033[38;5;214m"
RED = "\033[31m"
RESET = "\033[0m"

display_output = True


def no_output():
    global display_output
    display_output = False


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
    if error_level < 0:
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


def run_command(commands, flag_error=True, capture_output=True, timeout=None, as_user=None):
    """
    Execute a shell command and return the output.

    Args:
        commands (str|list): The commands to run.
        capture_output (bool): Capture the output.
        flag_error (bool): Flag whether to exit with an error.
        timeout (float|None): Optional timeout for command execution.
        as_user (str|None): User to run the command as.

    Returns:
        A string or a boolean based on capture_output.
    """
    if isinstance(commands, str):
        command_str = commands
        commands = shlex.split(commands)
    else:
        command_str = " ".join(commands)

    if as_user:
        commands = [ "su", "-", as_user, "-c", command_str ]

    try:
        if capture_output:
            result = subprocess.run(
                    commands,
                    timeout=timeout,
                    shell=True,
                    capture_output=True,
                    text=True,
                    env=os.environ
            )
        else:
            result = subprocess.run(
                commands,
                timeout=timeout,
                check=True,
                env=os.environ
            )

        if result.returncode != 0:
            if flag_error:
                display_message(89, f"Command '{command_str}' failed with exit code {result.returncode}.")
                display_message(89, f"Error: {result.stderr}")
            return "" if capture_output else False

        return result.stdout if capture_output else True

    except subprocess.TimeoutExpired:
        return "" if capture_output else False
    except subprocess.CalledProcessError as e:
        display_message(90, f"Error: Error running {command_str}. Error: {str(e)}")
        return "" if capture_output else False


def run_long_command(command, flag_error=True, capture_output=True, timeout=None, as_user=None):
    """
    Execute a shell command and return the output.
    This command displays a spinner and is used for long-running commands.

    Args:
        command (str): The command to run.
        capture_output (bool=False): Capture the output.
        flag_error (bool=False): Flag whether to exit with an error.
        timeout (float|None): Optional timeout for command execution.
        as_user (str|None): User to run the command as.

    Returns:
        A string or a boolean based on capture output.
    """

    stop_event = threading.Event()
    spinner_thread = threading.Thread(target=spinner, args=(stop_event,))

    spinner_thread.start()  # Start spinner

    result = run_command(command, flag_error, capture_output, timeout, as_user)

    stop_event.set()  # Stop spinner
    spinner_thread.join()  # Wait for spinner to finish
    sys.stdout.write('\n')  # Move to new line after completion

    return result


def spinner(stop_event):
    """
    Display a spinner on the command line.

    Args:
        stop_event (StopEvent): The event to stop the spinner.
    """
    spinner_symbols = itertools.cycle(['-', '\\', '|', '/'])

    while not stop_event.is_set():  # Run until stop_event is set
        sys.stdout.write(next(spinner_symbols))
        sys.stdout.flush()
        time.sleep(0.5)
        sys.stdout.write('\b')

    sys.stdout.write('\b')
    sys.stdout.flush()


def user_exists(username):
    """
    Check if a user exists in the system.

    Args:
        username (str): The username to check.

    Returns:
        bool: True if the user exists in the system.
    """
    return bool(run_command(f"id {username}", flag_error=False))


def directory_exists(path, parent=True):
    """
    Check if a directory exists in the system.

    Args:
        path (str): The path to check.
        parent(boll=False): If True, check if the parent directory exists.
    Returns:
        bool: True if the directory exists in the system.
    """
    if parent:
        return Path(path).parent.exists()
    else:
        return Path(path).exists()


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
    return value is not None and value.strip() != ""


def valid_integer(value):
    """
    Check if a value is present and is a string containing an integer.

    Args:
        value (str): The string to check.
    Returns:
        bool: True if the string contains a valid integer.
    """
    return value.isdigit()


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
                file.write(f"{key.upper()}=\"{value}\"\n")
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

        process = subprocess.Popen(["sudo", "chpasswd"], stdin=subprocess.PIPE, text=True)
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
        None
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
    with open(filename, "a") as file:
        for line in lines:
            file.write(f"{line}\n")
