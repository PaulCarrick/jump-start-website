#!/bin/sh

# install_sudo.sh

set -e

echo "*** Installing SUDO and net tools Server..."
    apt-get update -qq
    apt-get install --no-install-recommends -y sudo iproute2 telnet curl
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
echo "*** SUDO Installed..."

if [ "$#" -ne 0 ]; then
    ./scripts/setup_sudo_users.sh $@
fi
# end of install_ssh.sh
