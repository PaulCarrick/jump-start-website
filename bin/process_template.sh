#!/bin/sh

# process_template.sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <file>" >&2
  exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found." >&2
  exit 2
fi

# Read the file line by line and replace environment variables
while IFS= read -r line; do
  echo "$line" | envsubst
done < "$input_file"
