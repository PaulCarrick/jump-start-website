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
      system("pg_restore --verbose --clean --if-exists --no-acl --no-owner -h localhost -U #{db_user} -d \"#{destination_db}\" #{dump_file}")

      if $?.success?
        puts "#{destination_db} database restored successfully."

        # pg_restore copies ar_internal_metadata verbatim from the source
        # database, which stamps this (destination) database as having last
        # run under the SOURCE environment (development). Left alone, that
        # trips ActiveRecord::EnvironmentMismatchError the next time anything
        # (e.g. maintain_test_schema! in rails_helper.rb) checks it against
        # the environment this database is actually meant to be used under.
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO ar_internal_metadata (key, value, created_at, updated_at)
          VALUES ('environment', #{ActiveRecord::Base.connection.quote(Rails.env)}, NOW(), NOW())
          ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
        SQL
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

    unless File.exist?(source_directory)
      # ActiveStorage creates this directory lazily on first upload, so a
      # fresh checkout with no attachments yet won't have it. There is
      # nothing to copy in that case - just make sure the destination
      # exists so specs that depend on tmp/storage don't fail.
      puts "#{source_directory} does not exist yet - creating an empty #{destination_directory} instead of copying."
      FileUtils.mkdir_p(destination_directory)
      next
    end

    puts "Copying files from #{source_directory} to #{destination_directory}..."
    system("cp -a #{source_directory} #{destination_directory}")

    if $?.success?
      puts "Successfully copied #{source_directory} to #{destination_directory}."
    else
      handle_error("Error: Failed to copy #{source_directory} to #{destination_directory}.", args[:interactive])
    end
  end
end
