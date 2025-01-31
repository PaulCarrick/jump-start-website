# lib/tasks/duplicate_database.rake
namespace :db do
  desc "Replicate a database"
  task :replicate, [ :interactive ] => :environment do |t, args|
    args.with_defaults(interactive: false)

    # Invoke subtasks with the interactive argument
    Rake::Task["db:duplicate"].invoke(args[:interactive])
    Rake::Task["fs:duplicate"].invoke(args[:interactive])
  end
end

def prompt(message = "Press enter to continue...")
  print "#{message}: " # Display the prompt message
  STDIN.gets.chomp # Explicitly read from STDIN to capture input
end

def handle_error(message, interactive = true, raise_error = true)
  puts message

  prompt if interactive

  if raise_error
    raise message
  else
    exit(1)
  end
end

namespace :db do
  desc "Duplicate database to another database"
  task :duplicate, [ :interactive ] => :environment do |t, args|
    source_db      = ENV["SOURCE_DATABASE"] || ENV["DB_DATABASE"]
    destination_db = ENV["DESTINATION_DATABASE"] || "#{ENV["DB_DATABASE"]}_test"
    db_user        = ENV["DB_USERNAME"] || "jump_start"
    dump_file      = ENV["DATABASE_FILE"] || "tmp/dev_db.dump"

    puts "Dumping #{source_db}..."
    system("pg_dump -Fc --no-acl --no-owner -h localhost -U #{db_user} #{source_db} > #{dump_file}")

    if $?.success?
      puts "#{source_db} Database dumped successfully. Restoring to #{destination_db}..."
      system("pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{db_user} -d \"#{destination_db}\" #{dump_file}")

      if $?.success?
        puts "#{destination_db} database restored successfully."
      else
        handle_error("Error: Failed to restore the #{destination_db}  database.", args[:interactive])
      end
    else
      handle_error("Error: Failed to dump the #{source_db} database.", args[:interactive])
    end

    puts "Database #{source_db} duplication to  #{source_db} successful."
  end
end

namespace :fs do
  desc "Duplicate the contents of one directory to another"
  task :duplicate, [ :interactive ] => :environment do |t, args|
    source_directory      = ENV["SOURCE_DIRECTORY"] || Rails.root.join("storage")
    destination_directory = ENV["DESTINATION_DIRECTORY"] || Rails.root.join("tmp/storage")

    puts "Copying files from #{source_directory} to #{destination_directory}..."
    system("cp -a #{source_directory} #{destination_directory}")

    if $?.success?
      puts "Successfully copied #{source_directory} to #{destination_directory}."
    else
      handle_error("Error: Failed to copy #{source_directory} to #{destination_directory}.", args[:interactive])
    end
  end
end
