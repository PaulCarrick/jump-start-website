# The admin's Backup and restore page starts this in a separate process (see SiteBackup).
namespace :site_backup do
  desc "Runs the backup or restore described in tmp/backup/request.json"
  task run: :environment do
    SiteBackup.run_job!
  end
end
