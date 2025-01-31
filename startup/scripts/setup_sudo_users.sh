#!/bin/sh

# setup_sudo_users.sh
set -e

# Check for at least one username
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 username1 [username2 ...]" >&2
    exit 1
fi

# Loop through each username provided as an argument
for username in "$@"; do
    echo "Adding ${username} to the sudo group..."

    # Check if the user exists
    if id "${username}" >/dev/null 2>&1; then
        sudo_file="/etc/sudoers.d/${username}"

        if [ ! -f "${sudo_file}" ]; then
            # Add the user to the sudo group
            echo "${username} ALL=(ALL) NOPASSWD:ALL" > ${sudo_file}
            chmod 0440 /${sudo_file}
            # usermod -aG sudo "${username}"
            echo "User ${username} setup for sudo."
        else
            echo "User ${username} is already setup for sudo."
        fi
    else
        echo "Error: User ${username} does not exist. Skipping..." >&2
    fi
done

echo "*** SUDO access setup completed for all provided users. ***"
# End of setup_sudo_users.sh
