#!/bin/sh

# set_ssh_key.sh

set -e

username=$1
ssh_key_file=$2
working_dir=$3

# Validate input
if [ -z "${username}" ] || [ -z "${ssh_key_file}" ]; then
    echo "Usage: $0 USERNAME SSH_KEY_FILE [WORKING_DIR]" >&2
    exit 1
fi

if [ -n "${working_dir}" ]; then
    if [ ! -d "${working_dir}" ]; then
        echo "Error: Working directory '${working_dir}' does not exist." >&2

        exit 1
    fi

    cwd=$(pwd)

    cd "${working_dir}"
else
    cwd=""
    working_dir=.
fi

if [ ! -f "${ssh_key_file}" ]; then
    echo "Error: SSH key file '${ssh_key_file}' not found." >&2
    exit 2
fi

user_home="/home/${username}"
ssh_dir="${user_home}/.ssh"
auth_keys="${ssh_dir}/authorized_keys"

# Ensure the user exists
if ! id "${username}" >/dev/null 2>&1; then
    echo "Error: User '${username}' does not exist." >&2
    exit 3
fi

if [ ! -d "" ]; then
    scripts/create_ssh_for_user.sh ${username}
fi

# Append the key if authorized_keys already exists
if [ -f "${auth_keys}" ]; then
    echo "Appending SSH key to authorized_keys..."
    cat "${ssh_key_file}" >>"${auth_keys}"
else
    echo "Creating new authorized_keys and adding SSH key..."
    cp "${ssh_key_file}" "${auth_keys}"
fi

# Set correct permissions
chmod 600 "${auth_keys}"
chown "${username}:${username}" "${auth_keys}"

# Return to the original directory
[ -n "${cwd}" ] && cd "${cwd}"

echo "SSH public key successfully added for user '${username}'."
# end of set_ssh_key.sh
