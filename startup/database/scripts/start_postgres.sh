#!/bin/sh

# start_postgres.sh

set -e

working_dir=$1

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

# Check if PostgreSQL cluster is already initialized
if [ ! -d "/var/lib/postgresql/15/main" ]; then
    echo "Initializing PostgreSQL cluster..."

    pg_createcluster 15 main || {
        echo "Error: Could not initialize PostgreSQL cluster." >&2

        [ -n "${cwd}" ] && cd "${cwd}"

        exit 2
    }

    pg_hba_source="templates/pg_hba.conf"
    pg_hba_dest="/etc/postgresql/15/main/pg_hba.conf"

    if [ -f "${pg_hba_dest}" ] && [ -f "${pg_hba_source}" ]; then
        if [ -z "$(grep ${DB_USERNAME} ${pg_hba_dest})" ]; then
            echo "Updating pg_hba.conf..."

            bin/process_template.sh "${pg_hba_source}" >> "${pg_hba_dest}" || {
                echo "Error: Could not update ${pg_hba_dest}." >&2

                [ -n "${cwd}" ] && cd "${cwd}"

                exit 4
            }
        fi
    else
        echo "Error: pg_hba.conf source or destination file not found." >&2

        [ -n "${cwd}" ] && cd "${cwd}"

        exit 3
    fi
fi

if service postgresql start; then
    echo "PostgreSQL started successfully."
else
    echo "Error: Cannot start postgres server." >&2

    [ -n "${cwd}" ] && cd "${cwd}"

    exit 5
fi

# Return to the original directory
[ -n "${cwd}" ] && cd "${cwd}"

exit 0
# End of start_postgres.sh
