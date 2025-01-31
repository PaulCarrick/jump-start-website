#!/bin/bash
# encode-password.sh

# Initialize variables
password=${PASSWORD}
code_one=${CODE_ONE}
code_two=${CODE_TWO}
generated_codes="false"

# Parse options
while getopts ":p:1:2:h-:" opt; do
    case "$opt" in
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
            echo "Usage: $0 [-p|--password PASSWORD] [-1|--code-one LONG_KEY] [-2|--code-two SHORT_VALUE] [-h|--help]"
            echo "    -p --password The password you want to encrypt. If not present you will be prompted for it."
            echo "    -1 --code-one The 32 encryption key. If not present, one will be generated for you."
            echo "    -2 --code-two The 16 IV (value). If not present, one will be generated for you."
            exit 0
            ;;
        -)  # Handle long options
            case "$OPTARG" in
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
                    echo "Usage: $0 [-p|--password PASSWORD] [-1|--code-one LONG_KEY] [-2|--code-two SHORT_VALUE] [-h|--help]"
                    echo "    -p --password The password you want to encrypt. If not present you will be prompted for it."
                    echo "    -1 --code-one The 32 encryption key. If not present, one will be generated for you."
                    echo "    -2 --code-two The 16 IV (value). If not present, one will be generated for you."
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

# Prompt for password if not provided
if [ -z "$password" ]; then
    read -p "Enter the password to encrypt: " password
fi

if [ -z "$password" ]; then
    echo "A password is required."
    exit 2
fi

# Generate keys if not provided
if [ -z "$code_one" ]; then
    generated_codes="true"
    code_one=$(openssl rand -hex 32)
    export CODE_ONE="$code_one"
fi

if [ -z "$code_two" ]; then
    generated_codes="true"
    code_two=$(openssl rand -hex 16)
    export CODE_TWO="$code_two"
fi

# Encrypt the password
encoded_password=$(echo -n "$password" | openssl enc -aes-256-cbc -e -base64 -K "$code_one" -iv "$code_two")
export PASSWORD="$encoded_password"

if [ "$generated_codes" = "true" ] && [ -n "$code_one" ] && [ -n "$code_two" ]; then
    echo "CODE_ONE=${code_one}" > secrets/codes
    echo "CODE_TWO=${code_two}" >> secrets/codes
fi

echo "$encoded_password"
