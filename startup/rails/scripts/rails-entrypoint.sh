#!/bin/sh
# rails-entrypoint.sh

# Setup the environment
status="Okay"
cd /rails

if [ -f "./.env" ]; then
  set -a
    . ./.env

    if [ $? -ne 0 ]; then
      echo "*** Cannot load environment file ./.env ***"

      status=""
    fi
  set +a
else
  echo "*** Cannot find environment file ./.env ***"

  status=""
fi

# Optionally start the SSH server
if [ -n "$status" ] && [ -n "$SSH_PORT" ]; then
    echo "Starting SSHD."

    sudo service ssh start

    if [ $? -eq 0 ]; then
        echo "SSH service started."
    else
        echo "Could not start SSHD service." >&2

        # Not critical to server. It just means that a console will have to be used, so no error flagged.
    fi
fi

# Optionally setup the user for SSH this is need for users that have home directories mounted
public_key_file="/rails/setup/$SSH_PUBLIC_KEY"

if [ -n "$status" ] && [ -n "$USERNAME" ] && [ -f "$public_key_file" ] && [ ! -f "/home/${USERNAME}/.ssh/authorized_keys" ]; then
    sudo scripts/set_ssh_key.sh ${USERNAME} setup/${SSH_PUBLIC_KEY}
fi

# Start the Rails application
if [ -n "$status" ]; then
    echo "Starting Rails startup script..."

    # remove old pid in case it was left around from a previous instance
    rm -f /rails/tmp/pids/server.pid

#     su rails -c "/rails/scripts/rails-startup.sh"
    scripts/rails-startup.sh

    STARTUP_STATUS=$?

    if [ $STARTUP_STATUS -ne 0 ]; then
      echo "Error: rails-startup.sh exited with status $STARTUP_STATUS." >&2
    fi
fi

trap 'echo "Terminating..."; exit 0' TERM
trap 'echo "Terminating..."; exit 0' INT

# Keep the container running if the server is stopped or in the case of an error.
while true; do
    sleep 300
done
