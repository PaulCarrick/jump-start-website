# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "shellwords"

# Backup and restore for the admin's "Backup and restore" page.
#
# The files are the same as those made by bin/backup_database.sh and read by
# bin/load_database.sh, so the two can be used interchangeably:
#
#   <database>_database_<MM-DD-YYYY>.dump   pg_dump custom format, one per site database
#   <database>_images_<MM-DD-YYYY>.tar.gz   the storage/ folder (uploaded pictures and files)
#
# The images archive is named after the main database, as the script names it.
# Backups are never kept on the server: the page saves them on the administrator's
# computer and then deletes the server's copies. A restore uploads them again.
#
# The work runs in a separate process (bin/rails site_backup:run), because it can
# take minutes. Its progress is in tmp/backup/status.json; one job runs at a time.
class SiteBackup
  class Error < StandardError; end

  # The database's name comes before "_database_"; anything may follow it before the
  # extension (the script writes the date, a hand-made copy may add words, for example
  # rails_database_before_menu_position_11-09-2026.dump).
  DATABASE_FILE = /\A(?<database>[A-Za-z0-9_-]+?)_database_[A-Za-z0-9_.-]*\.dump\z/
  IMAGES_FILE = /\A(?<database>[A-Za-z0-9_-]+?)_images_[A-Za-z0-9_.-]*\.tar\.gz\z/
  CHUNK_BYTES = 8 * 1024 * 1024
  MAX_UPLOAD_BYTES = 20 * 1024 * 1024 * 1024
  STALE_UPLOAD_SECONDS = 24 * 60 * 60

  class << self
    def directory = Rails.root.join("tmp", "backup")
    def files_directory = directory.join("files")
    def incoming_directory = directory.join("incoming")
    def safety_directory = directory.join("before_restore")
    def status_file = directory.join("status.json")
    def log_file = directory.join("job.log")
    def request_file = directory.join("request.json")
    def storage_directory = Rails.root.join("storage")

    # The main database and every site database that is ready.
    def databases
      main = CatalogRecord.connection_db_config.database
      sites = SiteDatabase.where(bootstrapped: true).order(:name).pluck(:name)
      ([ main ] + sites).uniq
    end

    def main_database = databases.first

    def status
      data = status_file.exist? ? JSON.parse(status_file.read) : {}
      data = { "state" => "idle" }.merge(data)
      if data["state"] == "running" && !process_alive?(data["pid"])
        data = data.merge("state" => "failed", "error" => "The job stopped unexpectedly. See #{log_file} on the server.")
      end
      data["files"] = finished_files
      data["uploads"] = uploaded_files
      data
    rescue JSON::ParserError
      { "state" => "idle", "files" => finished_files, "uploads" => uploaded_files }
    end

    def running? = status["state"] == "running"

    # Starts a backup of the chosen databases and, when asked, the images.
    def start_backup!(databases:, images:)
      databases = Array(databases).map(&:to_s) & self.databases
      raise Error, "Choose at least one database or the images." if databases.empty? && !images
      raise Error, "Delete or save the last backup on the server first." if finished_files.any?

      start!("backup", "databases" => databases, "images" => images ? true : false)
    end

    # Restores every uploaded file: each database file into the database chosen for it
    # (by default the one its name gives), the images archive into storage/.
    def start_restore!(targets: {})
      plan = restore_plan
      raise Error, "Upload at least one backup file first." if plan.empty?

      chosen = plan.each_with_object({}) do |item, result|
        next unless item["kind"] == "database"

        target = targets[item["file"]].presence || item["target"]
        raise Error, "Choose the database #{item['file']} should replace." if target.blank?
        raise Error, "There is no database #{target} on this site." unless databases.include?(target)

        result[item["file"]] = target
      end
      if chosen.values.uniq.size < chosen.size
        raise Error, "Two files would replace the same database. Choose a different database for one of them."
      end

      start!("restore", "files" => plan.map { |item| item["file"] }, "targets" => chosen)
    end

    # What a restore of these files would do, for the page to show. A database file's
    # target is the database its name gives when this site has it; otherwise it is
    # chosen on the page (for example a backup of "rails" restored into "jump_start").
    def restore_plan(names = uploaded_files.map { |file| file["name"] })
      names.map do |name|
        kind, target = classify(name)
        { "file" => name, "kind" => kind, "target" => target, "choices" => kind == "database" ? databases : [] }
      end
    end

    # Tells what a file is and which database its name gives, or raises when it is not a backup file.
    def classify(name)
      if (match = DATABASE_FILE.match(name))
        [ "database", (databases.include?(match[:database]) ? match[:database] : nil) ]
      elsif IMAGES_FILE.match?(name)
        [ "images", "storage" ]
      else
        raise Error, "#{name} is not a backup file. Expected a name like rails_database_11-12-2026.dump or rails_images_11-12-2026.tar.gz."
      end
    end

    # Adds one part of an upload. A part must start where the file so far ends, so a
    # part sent twice is refused rather than written twice.
    def receive_part!(name:, offset:, data:, last:)
      raise Error, "A backup or restore is running." if running?
      classify(name)
      FileUtils.mkdir_p(incoming_directory)
      partial = incoming_directory.join("#{name}.part")
      partial.delete if offset.zero? && partial.exist?
      size = partial.exist? ? partial.size : 0
      raise Error, "The upload of #{name} is out of step (expected byte #{size}, got #{offset}). Start it again." unless size == offset
      raise Error, "#{name} is too large." if size + data.bytesize > MAX_UPLOAD_BYTES

      File.open(partial, "ab") { |file| file.write(data) }
      if last
        incoming_directory.join(name).delete if incoming_directory.join(name).exist?
        File.rename(partial, incoming_directory.join(name))
      end
      partial.exist? ? partial.size : incoming_directory.join(name).size
    end

    def discard_backup!
      raise Error, "A backup or restore is running." if running?
      FileUtils.rm_rf(files_directory)
    end

    def discard_uploads!
      raise Error, "A backup or restore is running." if running?
      FileUtils.rm_rf(incoming_directory)
    end

    def clear_status!
      raise Error, "A backup or restore is running." if running?
      status_file.delete if status_file.exist?
    end

    # The path of a finished backup file, or nil when the name is not one of them.
    def finished_file(name)
      file = files_directory.join(name.to_s)
      finished_files.any? { |item| item["name"] == name } && file.file? ? file : nil
    end

    # Runs the job described in tmp/backup/request.json (called by the rake task).
    def run_job!
      request = JSON.parse(request_file.read)
      case request["kind"]
      when "backup" then run_backup(request)
      when "restore" then run_restore(request)
      else raise Error, "Unknown job #{request['kind'].inspect}."
      end
    rescue StandardError => error
      write_status("state" => "failed", "error" => error.message, "finished_at" => Time.now.utc.iso8601)
      raise
    end

    private

    def start!(kind, details)
      raise Error, "A backup or restore is already running." if running?

      FileUtils.mkdir_p(directory)
      request_file.write(JSON.pretty_generate(details.merge("kind" => kind)))
      write_status("state" => "running", "kind" => kind, "step" => "Starting", "started_at" => Time.now.utc.iso8601)
      log = File.open(log_file, "w")
      pid = Process.spawn(Rails.root.join("bin", "rails").to_s, "site_backup:run",
                          chdir: Rails.root.to_s, out: log, err: log, pgroup: true)
      log.close
      Process.detach(pid)
      write_status("state" => "running", "kind" => kind, "step" => "Starting", "pid" => pid, "started_at" => Time.now.utc.iso8601)
      pid
    end

    def run_backup(request)
      FileUtils.rm_rf(files_directory)
      FileUtils.mkdir_p(files_directory)
      date = Time.now.strftime("%m-%d-%Y")
      request["databases"].each do |database|
        step!("backup", "Backing up the database #{database}")
        run!("pg_dump", *connection_arguments, "-d", database, "-F", "c", "-f", files_directory.join("#{database}_database_#{date}.dump").to_s)
      end
      if request["images"]
        step!("backup", "Packing the images (storage/)")
        archive = files_directory.join("#{main_database}_images_#{date}.tar.gz")
        run!("tar", "--dereference", "-czf", archive.to_s, "-C", Rails.root.to_s, "storage/")
      end
      write_status("state" => "done", "kind" => "backup", "finished_at" => Time.now.utc.iso8601,
                   "message" => "The backup is ready to save.")
    end

    def run_restore(request)
      targets = request["targets"] || {}
      files = request["files"].map do |name|
        kind, = classify(name)
        [ name, kind, kind == "database" ? targets.fetch(name) : "storage" ]
      end
      missing = files.reject { |name, _kind, _target| incoming_directory.join(name).file? }
      raise Error, "#{missing.map(&:first).join(', ')} was not uploaded completely." if missing.any?

      restored_databases = []
      files.select { |_name, kind, _target| kind == "database" }.each do |name, _kind, database|
        step!("restore", "Saving the current #{database} database before replacing it")
        FileUtils.mkdir_p(safety_directory)
        run!("pg_dump", *connection_arguments, "-d", database, "-F", "c",
             "-f", safety_directory.join("#{database}_before_restore.dump").to_s)
        step!("restore", "Restoring the database #{database} from #{name}")
        restore_database(database, incoming_directory.join(name))
        restored_databases << database
      end
      if restored_databases.include?(main_database)
        step!("restore", "Bringing the main database up to date")
        run!(Rails.root.join("bin", "rails").to_s, "db:migrate")
      end
      warnings = []
      if restored_databases.any? && databases.size > 1
        step!("restore", "Bringing the site databases up to date")
        begin
          run!(Rails.root.join("bin", "rails").to_s, "site_databases:migrate")
        rescue Error => error
          # A restored main database may list a second site whose database this server lacks.
          warnings << "The second sites' databases could not all be brought up to date (#{error.message.lines.last.to_s.strip}). " \
                      "Run bin/rails site_databases:migrate on the server."
        end
      end
      files.select { |_name, kind, _target| kind == "images" }.each do |name, _kind, _target|
        step!("restore", "Restoring the images from #{name}")
        restore_images(incoming_directory.join(name))
      end
      FileUtils.rm_rf(incoming_directory)
      write_status("state" => "done", "kind" => "restore", "finished_at" => Time.now.utc.iso8601,
                   "restored" => files.map(&:first), "warnings" => warnings,
                   "message" => "Restored #{files.map(&:first).join(', ')}. The site restarts in a few seconds; " \
                                "if the database was restored, log in again with an account from the backup.")
    rescue StandardError
      FileUtils.rm_rf(incoming_directory)
      raise
    ensure
      # Puma's tmp_restart plugin restarts the server, so no connection keeps the old tables.
      FileUtils.touch(Rails.root.join("tmp", "restart.txt")) if restored_databases&.any?
    end

    # The database is emptied and loaded in one transaction, so a failed restore leaves it as it was.
    def restore_database(database, dump)
      script = directory.join("restore-#{database}.sql")
      run!("pg_restore", "--no-owner", "--no-privileges", "-f", script.to_s, dump.to_s)
      # A newer pg_restore writes settings an older server does not know (PostgreSQL 17's
      # transaction_timeout on a 15 server); they are not needed to load the data.
      body = script.read.gsub(/^SET transaction_timeout = .*\n/, "")
      script.write("SET lock_timeout = '60s';\nDROP SCHEMA public CASCADE;\nCREATE SCHEMA public;\n#{body}")
      run!("psql", *connection_arguments, "-d", database, "-v", "ON_ERROR_STOP=1", "--single-transaction", "-q", "-f", script.to_s)
    ensure
      script&.delete if script&.exist?
    end

    # Unpacks the archive first, so a broken archive leaves storage/ as it was. storage/
    # can be a link to a Docker volume: its contents are replaced, not the link.
    def restore_images(archive)
      unpacked = directory.join("images")
      FileUtils.rm_rf(unpacked)
      FileUtils.mkdir_p(unpacked)
      run!("tar", "-xzf", archive.to_s, "-C", unpacked.to_s)
      source = unpacked.join("storage")
      raise Error, "#{archive.basename} has no storage/ folder." unless source.directory?

      FileUtils.mkdir_p(storage_directory)
      storage_directory.children.each { |child| FileUtils.rm_rf(child) }
      source.children.each { |child| FileUtils.cp_r(child, storage_directory.join(child.basename), preserve: true) }
    ensure
      FileUtils.rm_rf(unpacked) if unpacked
    end

    def connection_arguments
      config = CatalogRecord.connection_db_config.configuration_hash
      [ "-h", config[:host].to_s, "-p", config[:port].to_s, "-U", config[:username].to_s ]
    end

    # Runs a program without a shell; the database password goes in its environment.
    def run!(*command)
      password = CatalogRecord.connection_db_config.configuration_hash[:password].to_s
      output, result = Open3.capture2e({ "PGPASSWORD" => password }, *command)
      File.open(log_file, "a") { |log| log.puts("$ #{command.first} ...", output) }
      return if result.success?

      raise Error, "#{File.basename(command.first)} failed: #{output.lines.last(5).join.strip}"
    end

    def step!(kind, step)
      write_status("state" => "running", "kind" => kind, "step" => step, "pid" => Process.pid)
    end

    def write_status(data)
      FileUtils.mkdir_p(directory)
      temporary = directory.join("status.json.tmp")
      temporary.write(JSON.pretty_generate(data))
      File.rename(temporary, status_file)
    end

    def finished_files
      return [] unless files_directory.directory? && !running_backup?

      files_directory.children.select(&:file?).sort.map { |file| { "name" => file.basename.to_s, "size" => file.size } }
    end

    def running_backup?
      return false unless status_file.exist?

      data = JSON.parse(status_file.read)
      data["state"] == "running" && data["kind"] == "backup" && process_alive?(data["pid"])
    rescue JSON::ParserError
      false
    end

    def uploaded_files
      return [] unless incoming_directory.directory?

      incoming_directory.children.select(&:file?).sort.filter_map do |file|
        name = file.basename.to_s
        if name.end_with?(".part")
          file.delete if Time.now - file.mtime > STALE_UPLOAD_SECONDS
          next
        end
        { "name" => name, "size" => file.size }
      end
    end

    def process_alive?(pid)
      return false unless pid

      Process.kill(0, pid.to_i)
      true
    rescue Errno::ESRCH
      false
    rescue Errno::EPERM
      true
    end
  end
end
