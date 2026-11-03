#!/bin/sh

# configure_ssh.sh

set -e

username=$1
ssh_key_file=$2

echo "Configuring SSH..."

# Run the SSHD installation script
./scripts/install_ssh.sh

# Create the .ssh directory for the user
if [ -n "${username}" ]; then
    ./scripts/create_ssh_for_user.sh "${username}"
fi

# Set the SSH key for the user if provided
if [ -n "${username}" ] && [ -n "${ssh_key_file}" ]; then
    ./scripts/set_ssh_key.sh "${username}" "${ssh_key_file}"
fi

echo "SSH configuration completed."
# end of configure_ssh.sh
