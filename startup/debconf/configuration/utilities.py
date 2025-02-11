#!/usr/bin/env python3

# Utility functions

import sys
import os
import subprocess
from pathlib import Path


# ANSI color codes for terminal messages
GREEN = "\033[32m"
ORANGE = "\033[38;5;214m"
RED = "\033[31m"
RESET = "\033[0m"


def display_message(error_level, message):
    """
    Displays a message to the console with a given error level
     and optionally exit with a non-zero exit code if the error level
     is above 19.

    Args:
        error_level (int): The amount to increment the current_error_level.
        message (str): The message to display.

    error_level contains the current error level.
     display_message considers any error level above 19 as a fatal error.
     It subtracts 19 so that the error exit starts at 1.
    0-9 is not an error and displays in green.
    10-19 is a warning and displays in orange.
    > 19 is an error and display in red  then exits with an exit code
     of error_level - 19 (starts at 1 for 20).
    """
    if error_level < 10:
        print(f"{GREEN}{message}{RESET}")
    elif error_level < 20:
        print(f"{ORANGE}{message}{RESET}")
    else:
        print(f"{RED}{message}{RESET}", file=sys.stderr)
        sys.exit(error_level - 19)


def run_command(command, flag_error=True, capture_output=True, timeout=None):
    """
    Execute a shell command and return the output.

    Args:
        command (str): The command to run.
        capture_output (bool=False): Capture the output.
        flag_error (bool=False): Flag whether to exit with an error.

    Returns:
        A string or a boolean based on capture output.
    """
    result = None

    try:
        if timeout:
            result = subprocess.run(command,
                                    timeout=timeout,
                                    shell=True,
                                    capture_output=True,
                                    text=True,
                                    env=os.environ)
        else:
            result = subprocess.run(command,
                                    shell=True,
                                    capture_output=True,
                                    text=True,
                                    env=os.environ)

        if result.returncode != 0:
            if flag_error:
                display_message(89,
                                f"Command '{command}' failed with exit code {result.returncode}.\n"
                                f"{result.stderr}")
            else:
                if capture_output:
                    result = ""
                else:
                    result = False
        else:
            if capture_output:
                result = result.stdout
            else:
                result = True
    except subprocess.TimeoutExpired:
        if capture_output:
            result = ""
        else:
            result = False
    except subprocess.CalledProcessError as e:
        display_message(90,
                        f"Error: Error running {command}. Error: {str(e)}")

    return result


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


def present(value):
    return value is not None and value.strip() != ""


def valid_integer(value):
    return value.isdigit()


def valid_boolean_response(response):
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
    display_message(0, 'Setting up user: {username}...')
    run_command("useradd -m -s /bin/bash {owner}", True, False)

    try:
        display_message(0, 'Setting passwod for user: {username}...')

        process = subprocess.Popen(["sudo", "chpasswd"], stdin=subprocess.PIPE, text=True)
        process.communicate(input=f"{username}:{password}")

        if process.returncode == 0:
            display_message(0, f"Password successfully set for user: {username}.")
        else:
            display_message(92, f"Failed to set password for user: {username}.")
    except subprocess.SubprocessError as e:
        display_message(93, f"Error setting password for {username}: {e}")

    display_message(0, 'User: {username} setup complete.')
