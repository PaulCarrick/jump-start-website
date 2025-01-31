#!/bin/sh

# setup_user.sh
set -e

username=$1
password=$2
user_id=$3
home_directory=$4

if [ -z "${username}" ] || [ -z "${password}" ]; then
    echo "Usage: $0 USERNAME PASSWORD [USER_ID] [HOME_DIRECTORY]" >&2
    exit 1
fi

echo "*** Setting up user: ${username} ***"

# Check if the user already exists
if ! id "${username}" >/dev/null 2>&1; then
    # Add the group
    if [ -n "${user_id}" ]; then
        if ! getent group "${username}" >/dev/null 2>&1; then
            groupadd --system --gid "${user_id}" "${username}"
        fi
    else
        if ! getent group "${username}" >/dev/null 2>&1; then
            groupadd --system "${username}"
        fi
    fi

    # Add the user
    if [ -n "${home_directory}" ]; then
        useradd --home-dir "${home_directory}" --shell /bin/bash \
            ${user_id:+--uid "${user_id}"} --gid "${username}" "${username}"
    else
        useradd --create-home --shell /bin/bash \
            ${user_id:+--uid "${user_id}"} --gid "${username}" "${username}"

        home_directory="/home/${username}"
    fi

    if [ -d "${home_directory}" ]; then
        chown -R "${username}:${username}" "${home_directory}"
    fi

    echo "*** User ${username} setup successfully ***"
else
    echo "User ${username} already exists. Skipping creation."
fi

echo "${username}:${password}" | chpasswd
# end of setup_user
