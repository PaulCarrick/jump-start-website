# !/bin/sh

# Check if there are any files in the directory
if ls tmp/capybara/* 1> /dev/null 2>&1; then
# Files exist, invoke rm_tool
    bin/rm_tool.rb tmp/capybara/*
    echo "Capybara images cleared."
else
# No files found
    echo "No Capybara images to clear."
fi
