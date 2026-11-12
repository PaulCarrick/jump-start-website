require 'rails_helper'

# The backup files must stay those of bin/backup_database.sh and bin/load_database.sh.
RSpec.describe SiteBackup do
  let(:work) { Pathname.new(Dir.mktmpdir('site-backup')) }
  let(:storage) { Pathname.new(Dir.mktmpdir('site-storage')) }
  let(:main) { described_class.main_database }

  before do
    allow(described_class).to receive(:directory).and_return(work)
    allow(described_class).to receive(:storage_directory).and_return(storage)
  end

  after { FileUtils.rm_rf([ work, storage ]) }

  it 'reads the file names the scripts write, and those with words before the date' do
    expect(described_class.classify("#{main}_database_11-12-2026.dump")).to eq([ 'database', main ])
    expect(described_class.classify("#{main}_database_before_menu_position_11-09-2026.dump")).to eq([ 'database', main ])
    expect(described_class.classify('rails_images_11-12-2026.tar.gz')).to eq([ 'images', 'storage' ])
    # A database this site lacks has no target until one is chosen.
    expect(described_class.classify('some-other-site_database_11-12-2026.dump')).to eq([ 'database', nil ])
    expect { described_class.classify('notes.txt') }.to raise_error(SiteBackup::Error, /not a backup file/)
    expect { described_class.classify('../etc_database_1.dump') }.to raise_error(SiteBackup::Error)
  end

  it 'takes an upload in parts, in order only' do
    name = "#{main}_database_11-12-2026.dump"
    expect(described_class.receive_part!(name: name, offset: 0, data: 'abc', last: false)).to eq(3)
    expect { described_class.receive_part!(name: name, offset: 0 + 10, data: 'x', last: false) }
      .to raise_error(SiteBackup::Error, /out of step/)
    described_class.receive_part!(name: name, offset: 3, data: 'def', last: true)
    expect(work.join('incoming', name).read).to eq('abcdef')
    expect(described_class.status['uploads']).to eq([ { 'name' => name, 'size' => 6 } ])
  end

  it 'needs a chosen database for a file whose name gives none, and refuses two files for one database' do
    described_class.receive_part!(name: 'elsewhere_database_11-12-2026.dump', offset: 0, data: 'x', last: true)
    expect { described_class.start_restore! }.to raise_error(SiteBackup::Error, /Choose the database/)
    expect { described_class.start_restore!(targets: { 'elsewhere_database_11-12-2026.dump' => 'nope' }) }
      .to raise_error(SiteBackup::Error, /no database nope/)
    described_class.receive_part!(name: "#{main}_database_11-12-2026.dump", offset: 0, data: 'y', last: true)
    expect { described_class.start_restore!(targets: { 'elsewhere_database_11-12-2026.dump' => main }) }
      .to raise_error(SiteBackup::Error, /same database/)
  end

  it 'backs up into the scripts\' file names and restores the images archive into storage' do
    storage.join('picture.jpg').write('old picture')
    commands = []
    allow(described_class).to receive(:run!).and_wrap_original do |original, *command|
      commands << command
      command.first == 'tar' ? original.call(*command) : File.write(command[command.index('-f') + 1], 'dump')
    end
    allow(Rails).to receive(:root).and_return(storage.dirname)
    allow(described_class).to receive(:storage_directory).and_return(storage.dirname.join('storage'))
    real_storage = storage.dirname.join('storage')
    FileUtils.mkdir_p(real_storage)
    real_storage.join('picture.jpg').write('backed up picture')

    work.join('request.json').write({ kind: 'backup', databases: [ main ], images: true }.to_json)
    described_class.run_job!
    names = described_class.status['files'].map { |file| file['name'] }
    date = Time.now.strftime('%m-%d-%Y')
    expect(names).to contain_exactly("#{main}_database_#{date}.dump", "#{main}_images_#{date}.tar.gz")
    expect(commands.map(&:first)).to eq(%w[pg_dump tar])

    # Restore that archive: the picture comes back as it was in the backup.
    FileUtils.mkdir_p(work.join('incoming'))
    FileUtils.cp(work.join('files', "#{main}_images_#{date}.tar.gz"), work.join('incoming'))
    real_storage.join('picture.jpg').write('changed since')
    real_storage.join('new.jpg').write('added since')
    work.join('request.json').write({ kind: 'restore', files: [ "#{main}_images_#{date}.tar.gz" ], targets: {} }.to_json)
    allow(FileUtils).to receive(:touch)
    described_class.run_job!
    expect(real_storage.join('picture.jpg').read).to eq('backed up picture')
    expect(real_storage.join('new.jpg')).not_to exist
    expect(described_class.status).to include('state' => 'done', 'kind' => 'restore')
  ensure
    FileUtils.rm_rf(storage.dirname.join('storage')) if storage
  end
end
