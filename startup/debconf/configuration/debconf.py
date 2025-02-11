#!/usr/bin/env python3

# Class to handle deb_conf input.
# If deb_conf is installed it uses deb_conf otherwise it handles the input and output itself.

import sys
import os
import re
import subprocess
from types import SimpleNamespace
from .utilities import display_message, run_command, present
from .dialog import Dialog


class DebConf:
    def __init__(self, template_filename=None):
        self.templates = SimpleNamespace()
        self.template_filename = template_filename
        self._debconf_installed = False


    def __dict_to_namespace(self, d):
        """Recursively converts a dictionary into a SimpleNamespace object."""
        if isinstance(d, dict):
            return SimpleNamespace(**{k: self.__dict_to_namespace(v) for k, v in d.items()})
        return d


    def __parse_debconf_template(self, file_path):
        """Parses a Debconf template file and stores templates in self.templates."""
        entries = {}
        current_template = None
        current_field = None
        buffer = []

        with open(file_path, "r") as file:
            for line in file:
                line = line.strip()

                if not line or line.startswith("#"):  # Ignore comments and blank lines
                    continue

                match = re.match(r"^Template:\s*(.+)", line)
                if match:
                    # Save previous field
                    if current_template and current_field:
                        entries[current_template][current_field] = " ".join(buffer).strip()

                    current_template = match.group(1)
                    entries[current_template] = {"value": None}  # Initialize new template entry
                    current_field = None
                    buffer = []
                    continue

                field_match = re.match(r"^(Type|Default|Choices|Description):\s*(.+)", line)
                if field_match:
                    field_name = field_match.group(1)  # Type, Default, Choices, Description
                    value = field_match.group(2)

                    # Save previous field before switching
                    if current_template and current_field:
                        entries[current_template][current_field] = " ".join(buffer).strip()

                    # Handle "Choices" as an array
                    if field_name == "Choices":
                        entries[current_template]["choices"] = re.split(r",\s*", value)
                    else:
                        current_field = field_name.lower()  # Convert field name to lowercase
                        buffer = [value]  # Start new buffer

                    continue

                # Append to buffer for multi-line descriptions
                if current_template and current_field:
                    buffer.append(line)

        # Save last processed field
        if current_template and current_field:
            entries[current_template][current_field] = " ".join(buffer).strip()

        self.templates = self.__dict_to_namespace(entries)


    def __load_template(self, file_path):
        """Public method to parse a template file and store it in self.templates."""
        self.__parse_debconf_template(file_path)


    def __get_template(self, template_name):
        """Retrieve a parsed template."""
        return getattr(self.templates, template_name, None)


    def __is_debconf_installed(self):
        """Check to see if Debconf is installed."""
        result = None

        try:
            subprocess.run(["debconf-show", "--listdbs"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
            result = True
        except (FileNotFoundError, subprocess.CalledProcessError):
            result = False

        return result


    def initialize_debconf_environment(self):
        """Initialize the Debconf environment."""
        result = True

        if not self.__is_debconf_installed():
            self.__parse_debconf_template(self.template_filename)
            result = False

        if result:
            try:
                debconf_env = subprocess.check_output(
                        ". /usr/share/debconf/confmodule && env",
                        timeout=3,
                        shell=True,
                        text=True,
                        executable="/bin/bash"
                )

                for line in debconf_env.splitlines():
                    key, _, value = line.partition("=")
                    if key.startswith("DEBCONF_") or key.startswith("DEBIAN_"):
                        os.environ[key] = value
            except subprocess.TimeoutExpired:
                result = False
            except subprocess.CalledProcessError:
                result = False

        self._debconf_installed = result

        return result


    def __get_debconf_template(self, key):
        """Retrieve a template from parsed data."""
        return getattr(self.templates, key, None) if not self._debconf_installed else None


    def __get_debconf_value(self, key):
        """Retrieve a value from debconf."""
        result = None

        if not self.__is_debconf_installed():
            template = self.__get_debconf_template(key)

            if template:
                if template.type == "select":
                    [result, status] = Dialog.select(template.description, template.choices, template.default)
                else:
                    [result, status] = Dialog.input(template.description,
                                                    template.value,
                                                    template.default if hasattr(template, "default") else "")

                if (status == "Aborted") or (result == "Quit"):
                    display_message(10, "Installation aborted by user.")
                    sys.exit(0)
        else:
            run_command(f"db_get {key}")

            result = os.getenv("RET")

        return result


    def set_debconf_value(self, key, value):
        """Set a value in debconf."""
        result = None

        if not self.__is_debconf_installed():
            template = self.__get_debconf_template(key)

            if template:
                if template.type == "note":
                    template.description = value
                else:
                    template.default = value

                result = True
        else:
            result = run_command(f"db_set {key} \"{value}\"", True, False)

        return result


    def show_debconf_message(self, key, message):
        """Show a message using debconf."""
        if message:
            self.set_debconf_value(key, message)

        if not self.__is_debconf_installed():
            template = self.__get_debconf_template(key)

            if template:
                [ result, status ] = Dialog.show(template.description)

            if status == "Aborted":
                display_message(10, "Installation aborted by user.")
                sys.exit(0)
        else:
            run_command(f"db_fset {key} seen false", True, False)
            run_command(f"db_input critical {key}", True, False)
            run_command("db_go", True, False)


    def __show_debconf_error(self, message):
        """Show an error message using debconf."""
        self.show_debconf_message("jump-start-website/error", message)


    def set_template_filename(self, template_filename):
        self.template_filename = template_filename


    def get_validated_input(self, key, validation_func=None, error_message="Invalid input"):
        """
        Retrieve a valid input from debconf, validating it if needed.
        """
        while True:
            value = self.__get_debconf_value(key)

            if value and value.lower() == "quit":
                display_message(10, "Installation aborted by user.")
                sys.exit(0)

            if not value or (validation_func and not validation_func(value)):
                self.__show_debconf_error(error_message)
            else:
                return value


if __name__ == "__main__":
    debconf = DebConf("templates")
    debconf.initialize_debconf_environment()

    domain = debconf.get_validated_input("jump-start-website/domain",
                                         present,
                                         "You must enter a valid domain name.")

    print(domain)
