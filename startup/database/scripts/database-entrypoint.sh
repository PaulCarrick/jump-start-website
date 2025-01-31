#!/bin/sh
# database-entrypoint.sh

# Setup the environment
status="Okay"
database_populated=false

cd /database

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
public_key_file="/database/setup/$SSH_PUBLIC_KEY"

if [ -n "$status" ] && [ -n "$USERNAME" ] && [ -f "$public_key_file" ] && [ ! -f "/home/${USERNAME}/.ssh/authorized_keys" ]; then
    scripts/set_ssh_key.sh ${USERNAME} setup/${SSH_PUBLIC_KEY}
fi

scripts/start_postgres.sh

if [ $? -ne 0 ]; then
    echo "*** Cannot start postgres ***"

    status="" # Critical issue
fi

if [ -n "$status" ]; then
    scripts/setup_databases.sh

    if [ $? -ne 0 ]; then
        echo "*** Cannot setup databases ***"

        status="" # Critical issue
    else
        database_populated=true
    fi
fi

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Final status
if [ -n "$status" ]; then
    echo "Everything set up for the database."
else
    echo "Something went wrong." >&2
fi

trap 'echo "Terminating..."; exit 0' TERM
trap 'echo "Terminating..."; exit 0' INT

# Keep the container running
while true; do
    sleep 300
done
