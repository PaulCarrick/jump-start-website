#!/bin/sh

# setup_databases.sh
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

# Setup database User
sql_file="templates/create_database_user.sql"

if [ -f "${sql_file}" ]; then
    bin/process_template.sh "${sql_file}" | su - postgres -c "psql" || {
        echo "Error: Failed to process SQL file '${sql_file}'." >&2

        [ -n "${cwd}" ] && cd "${cwd}"

        exit 3
    }
else
    echo "Error: SQL file '${sql_file}' does not exist." >&2

    [ -n "${cwd}" ] && cd "${cwd}"

    exit 2
fi

# Loop through each database directory
for database_dir in databases/*; do
    if [ -d "${database_dir}" ]; then
        database_name=$(basename "${database_dir}")

        # Custom logic for certain databases; For future use
        case "${database_name}" in
            *)
                data_destination="storage"
                username="rails"
                ;;
        esac

        echo "Setting up database: ${database_name}"
        scripts/setup_database.sh "${database_name}" "${working_dir}" "${data_destination}" "${username}" || {
            echo "Error: Failed to set up database '${database_name}'." >&2

            [ -n "${cwd}" ] && cd "${cwd}"

            exit 4
        }
    fi
done

# Return to the original directory
[ -n "${cwd}" ] && cd "${cwd}"

echo "All databases have been set up successfully."
exit 0
# End of setup_databases.sh
