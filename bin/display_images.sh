#!/bin/sh

# Check if the directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Assign the directory from the argument
directory=$1

# Check if the directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 1
fi

# Loop through all .png files in the directory
for image in "$directory"/*.png; do
  # Check if any .png files are found
  if [ ! -e "$image" ]; then
    echo "No PNG images found in the directory."
    exit 0
  fi

  # Open the image
  echo "Opening $image"
  xdg-open "$image" 2>/dev/null || open "$image" 2>/dev/null
done
