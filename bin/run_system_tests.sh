# ~/bin/sh

if ls tmp/capybara/* 1> /dev/null 2>&1; then
    bin/rm_tool.rb tmp/capybara/*
fi

rspec spec/system
