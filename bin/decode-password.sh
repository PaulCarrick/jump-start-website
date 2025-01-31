#!/bin/bash
# decode-password.sh

# Initialize variables
username=""
password=${PASSWORD}
code_one=${CODE_ONE}
code_two=${CODE_TWO}

# Parse options
while getopts ":u:p:1:2:h-:" opt; do
    case "$opt" in
        u)  # Short option -u
            username="$OPTARG"
            ;;
        p)  # Short option -p
            password="$OPTARG"
            ;;
        1)  # Short option -1
            code_one="$OPTARG"
            ;;
        2)  # Short option -2
            code_two="$OPTARG"
            ;;
        h)  # Short option -h
            echo "Usage: $0 [-u|--user USERNAME][-p|--password PASSWORD] [-1|--code-one LONG_KEY] [-2|--code-two SHORT_VALUE]"
            echo "    -u --user An optional username. If provided the output will be USER:PASSWORD for input into chpasswd."
            echo "    -p --password The password you want to decrypt. If not present you will be prompted for it."
            echo "    -1 --code-one The 32 encryption key If not present you will be prompted for it."
            echo "    -2 --code-two The 16 IV (value) if not present you will be prompted for it."
            exit 0
            ;;
        -)  # Handle long options
            case "$OPTARG" in
                user)
                    username="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                password)
                    password="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                code-one)
                    code_one="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                code-two)
                    code_two="${!OPTIND}"; OPTIND=$((OPTIND + 1))
                    ;;
                help)
                    echo "Usage: $0 [-u|--user USERNAME][-p|--password PASSWORD] [-1|--code-one LONG_KEY] [-2|--code-two SHORT_VALUE]"
                    echo "    -u --user An optional username. If provided the output will be USER:PASSWORD for input into chpasswd."
                    echo "    -p --password The password you want to decrypt. If not present you will be prompted for it."
                    echo "    -1 --code-one The 32 encryption key If not present you will be prompted for it."
                    echo "    -2 --code-two The 16 IV (value) if not present you will be prompted for it."
                    exit 0
                    ;;
                *)
                    echo "Unknown option --$OPTARG" >&2
                    exit 1
                    ;;
            esac
            ;;
        ?)
            echo "Unknown option -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ -z "${password}" ]; then read -p "Enter the password to decrypt: " password ; fi

if [ -z "${password}" ]; then
    echo "A password is required." ;
    exit 2
fi

if [ -z "${code_one}" -a -f "secrets/codes" ]; then
    set -a
        . secrets/codes
    set +a

    code_one=${CODE_ONE}
    code_two=${CODE_TWO}
fi

if [ -z "${code_one}" ]; then read -p "Enter the 32 bit key for decryption: " code_one ; fi

if [ -z "${code_one}" ]; then
    echo "A 32 bit key is required." ;
    exit 3
fi

if [ -z "${code_two}" ]; then read -p "Enter the 16 bit value for decryption: " code_two ; fi

if [ -z "${code_two}" ]; then
    echo "A 16 bit value is required." ;
    exit 4
fi

decoded_password=$(echo -n "${password}" | base64 --decode | openssl enc -aes-256-cbc -d -K "${code_one}" -iv "${code_two}")
export PASSWORD=${decoded_password}

if [ -n "${username}" ]; then
    echo "${username}:${decoded_password}"
else
    echo "${decoded_password}"
fi
