#!/bin/sh

# install_ssh.sh

set -e

echo "*** Installing SSH Server..."
apt-get update -qq
apt-get install --no-install-recommends -y sudo openssh-server
rm -rf /var/lib/apt/lists /var/cache/apt/archives
echo "*** SSH Server Installed."

echo "*** Configuring SSH..."

# Ensure the runtime directory for SSH exists
mkdir -p /var/run/sshd

# Validate the template configuration file exists
if [ ! -f ./templates/configure_ssh.conf ]; then
    echo "Error: SSH configuration template './templates/configure_ssh.conf' not found." >&2
    exit 1
fi

# Copy the configuration file to the SSH directory
cp ./templates/configure_ssh.conf /etc/ssh/sshd_config

# Set correct permissions for the configuration file
chmod 600 /etc/ssh/sshd_config

echo "*** SSH Configured."
# end of install_ssh.sh
