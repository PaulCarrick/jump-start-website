#!/bin/sh

# create_ssh_for_user.sh

set -e

username=$1

if [ -z "${username}" ]; then
    echo "Usage: $0 USERNAME" >&2
    exit 1
fi

# Check if the user exists
if ! id "${username}" >/dev/null 2>&1; then
    echo "Error: User '${username}' does not exist." >&2
    exit 2
fi

user_home="/home/${username}"
ssh_dir="${user_home}/.ssh"

echo "Setting up SSH for user '${username}'..."

# Check if the .ssh directory already exists
if [ -d "${ssh_dir}" ]; then
    echo "Warning: SSH directory already exists for '${username}'. Ensuring correct permissions."
else
    echo "Creating SSH directory for '${username}'..."
    mkdir -p "${ssh_dir}"
fi

# Set permissions and ownership
chmod 700 "${ssh_dir}"
chown -R "${username}:${username}" "${ssh_dir}"

echo "SSH setup for user '${username}' is complete."
# end of create_ssh_for_user.sh
