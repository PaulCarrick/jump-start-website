#!/usr/bin/env ruby

# bin/setup.rb
# Configure Jump Start Server rails website

require "yaml"
require "erb"

# Setup variables
db_name       = ARGV[0] || "rails"
db_user       = ARGV[1] || "jump_start"
environment   = ENV["RAILS_ENV"] || "production"
rails_dir     = File.expand_path("..", File.dirname(__FILE__))
config_dir    = File.expand_path("config", rails_dir)
database_file = File.expand_path("database.yml", config_dir)

# Check for password
unless ENV['DB_PASSWORD'] && !ENV['DB_PASSWORD'].empty?
  STDERR.puts "Please set DB_PASSWORD to use this script."
  exit 1
end

# Load DB Configuration
db_config = YAML.load(ERB.new(File.read(database_file)).result)

# Update database configuration
db_config[environment]             ||= {}
db_config[environment]["host"]     = "localhost"
db_config[environment]["port"]     = 5432
db_config[environment]["database"] = db_name
db_config[environment]["username"] = db_user
db_config[environment]["password"] = ENV["DB_PASSWORD"]
db_config[environment]["pool"]     = 5

# Write the updated configuration back to file
File.open(database_file, "w") { |file| file.write(db_config.to_yaml) }

puts "Database configuration saved to #{database_file}."
