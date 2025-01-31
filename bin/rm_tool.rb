#!/usr/bin/env ruby

require 'fileutils'

# Helper method to print usage instructions
def print_usage
  puts <<-USAGE
Usage: rm_tool.rb [options] <file_or_directory>...

Options:
  -r   Recursively remove directories and their contents
  -f   Force removal without prompting
  -h   Show this help message
  USAGE
end

# Parse command-line arguments
options = { recursive: false, force: false }
targets = []

ARGV.each do |arg|
  case arg
  when '-r'
    options[:recursive] = true
  when '-f'
    options[:force] = true
  when '-h'
    print_usage
    exit
  else
    targets << arg
  end
end

# Exit if no targets are provided
if targets.empty?
  puts "Error: No files or directories specified."
  print_usage
  exit(1)
end

# Process each target
targets.each do |target|
  if File.exist?(target)
    if File.directory?(target)
      # Handle directories
      if options[:recursive]
        puts "Removing directory: #{target}" unless options[:force]
        FileUtils.rm_rf(target)
      else
        puts "Error: #{target} is a directory. Use -r to remove recursively."
      end
    else
      # Handle files
      puts "Removing file: #{target}" unless options[:force]
      File.delete(target)
    end
  else
    puts "Error: #{target} does not exist." unless options[:force]
  end
end
