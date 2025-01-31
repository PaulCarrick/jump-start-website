#!/bin/sh

# setup_database.sh
set -e

database=$1

if [ -z "${database}" ]; then
    echo "Usage: $0 DATABASE_NAME [WORKING_DIRECTORY] [DATA_DESTINATION] [USERNAME]" >&2
    exit 1
fi

export PGPASSWORD="${DB_PASSWORD}"
database_exists=$(su - postgres -c "psql -d postgres -tAc \"SELECT 1 FROM pg_database WHERE datname = '${database}';\"")

if [ "${database_exists}" = "1" ]; then
    echo "Database '${database}' already exists. Skipping setup."
    exit 0
fi

working_dir=$2

if [ -n "${working_dir}" ]; then
    if [ ! -d "${working_dir}" ]; then
        echo "Error: Working directory '${working_dir}' does not exist." >&2
        exit 2
    fi

    cwd=$(pwd)
    cd "${working_dir}"
else
    cwd=""
fi

sql_file="databases/${database}/setup_database.sql"

if [ ! -f "${sql_file}" ]; then
    echo "Error: SQL file '${sql_file}' does not exist or is not readable." >&2
    [ -n "${cwd}" ] && cd "${cwd}"
    exit 3
fi

sudo -u postgres psql -U postgres -c "CREATE DATABASE ${database};"
sudo -u postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${database} TO ${DB_USERNAME};"
sudo -u postgres psql -U postgres -c "ALTER DATABASE ${database} OWNER TO ${DB_USERNAME};"

dump_file="databases/${database}/dump.sql"

if [ -f "${dump_file}" ]; then
    echo "Restoring database from dump: ${dump_file}"
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USERNAME}" -d "${database}" -f "${dump_file}" || {
        echo "Error: Could not restore database from dump '${dump_file}'." >&2

        [ -n "${cwd}" ] && cd "${cwd}"

        exit 5
    }
fi

# Extract data files if needed
data_destination=$3

data_file="databases/${database}/data.tar.gz"

if [ -f "${data_file}" ] && [ -z "$(ls -A ${data_destination} 2>/dev/null)" ]; then
    echo "Extracting data files from: ${data_file}"

    rm -rf "${data_destination}"/*
    tar -xzvf "${data_file}" || {
        echo "Error: Could not extract data files from '${data_file}'." >&2

        [ -n "${cwd}" ] && cd "${cwd}"

        exit 6
    }

    username=$4

    if [ -n "${username}" ]; then
        echo "Setting ownership for data files to user '${username}'"
        chown -R "${username}:${username}" "${data_destination}"/*
    fi
fi

[ -n "${cwd}" ] && cd "${cwd}"

echo "Database setup for '${database}' completed successfully."
exit 0
# End of setup_database.sh
