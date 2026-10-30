require 'rails_helper'

RSpec.describe 'Bitemporal publishing' do
  after { PublishingContext.reset }

  BitemporalRecord::MODELS.each do |name|
    it "keeps #{name} edits unpublished, then atomically publishes its native version" do
      admin = create(:user, access: 'super')
      record = name == 'PostComment' ? create(:post_comment, blog_post: create(:blog_post)) : create(name.underscore.to_sym)
      original_version = record.version
      known_before = Time.current
      PublishingContext.editing = true
      record.update!(enabled: false)
      expect(record.version).to eq(original_version + 1)
      expect(record).to be_draft
      PublishingContext.live = true
      expect(record.class.find(record.id).enabled).to be(true)
      PublishingContext.live = false
      expect(record.class.find(record.id).enabled).to be(false)
      PublishingContext.editing = false
      deployment = Publishing.deploy!(actor: admin, summary: 'Publish disabled content')
      expect(deployment).to be_persisted
      PublishingContext.live = true
      expect(record.class.find(record.id).enabled).to be(false)
      historical = record.class.bitemporal_at(valid_at: known_before, known_at: known_before).where(id: record.id).first
      expect(historical.enabled).to be(true)
    end
  end

  it 'publishes replacement images with the same names as deleted unpublished uploads' do
    admin = create(:user, access: 'super')
    PublishingContext.editing = true
    old = create(:image_file, name: 'replacement-image')
    old.destroy!
    replacement = create(:image_file, name: 'replacement-image')
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Replace upload')
    PublishingContext.live = true
    expect(ImageFile.find_by(name: 'replacement-image').id).to eq(replacement.id)
    expect(ImageFile.find_by(id: old.id)).to be_nil
  end

  it 'releases the name of a deleted live page for a replacement in the same deployment' do
    admin = create(:user, access: 'super')
    old = create(:page)
    PublishingContext.editing = true
    old.destroy!
    replacement = create(:page, name: old.name, section: old.section)
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Replace page')
    PublishingContext.live = true
    expect(Page.find_by(name: old.name).id).to eq(replacement.id)
    expect(Page.find_by(id: old.id)).to be_nil
  end

  it 'keeps new records unpublished and discards them without affecting live content' do
    PublishingContext.editing = true
    record = create(:page)
    expect(record).to be_draft
    PublishingContext.live = true
    expect(Page.find_by(id: record.id)).to be_nil
    Publishing.discard!
    PublishingContext.live = false
    expect(Page.find_by(id: record.id)).to be_nil
  end

  it 'records multiple system-time corrections of the same pending version' do
    record = create(:page)
    PublishingContext.editing = true
    record.update!(title: 'First draft')
    draft_version = record.version
    record = Page.find(record.id)
    record.update!(title: 'Second draft')
    expect(record.version).to eq(draft_version)
    expect(Page.history.where(id: record.id, version: draft_version).count).to be >= 1
    PublishingContext.live = true
    expect(Page.find(record.id).title).not_to eq('Second draft')
  end

  it 'rejects stale editors instead of overwriting another pending edit' do
    record = create(:page)
    stale = Page.find(record.id)
    PublishingContext.editing = true
    record.update!(title: 'First editor')
    expect { stale.update!(title: 'Stale editor') }.to raise_error(ActiveRecord::StaleObjectError)
  end

  it 'stages deletion and leaves live content present until deployment' do
    admin = create(:user, access: 'super')
    record = create(:page)
    PublishingContext.editing = true
    record.destroy!
    PublishingContext.live = true
    expect(Page.find_by(id: record.id)).to be_present
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Delete page')
    expect(Page.find_by(id: record.id)).to be_nil
    expect(Page.history.where(id: record.id)).to exist
  end
  it 'restores historical content as a pending version without rewriting live content' do
    admin = create(:user, access: 'super')
    record = create(:page, title: 'Original title')
    PublishingContext.editing = true
    record.update!(title: 'Deployed title')
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Publish edit')
    Publishing.restore!(model: Page, id: record.id, version: 1)
    expect(Page.find(record.id).title).to eq('Original title')
    PublishingContext.live = true
    expect(Page.find(record.id).title).to eq('Deployed title')
  end

  it 'keeps an image replacement isolated and retains referenced bytes' do
    admin = create(:user, access: 'super')
    image = create(:image_file)
    original_blob = image.image.blob.id
    PublishingContext.editing = true
    File.open(Rails.root.join('spec/fixtures/files/sample.jpg'), 'rb') do |file|
      image.image = { io: file, filename: 'replacement.jpg', content_type: 'image/jpeg' }
    end
    image.save!
    replacement_blob = image.attachment_blob_id
    expect(replacement_blob).not_to eq(original_blob)
    PublishingContext.live = true
    expect(ImageFile.find(image.id).image.blob.id).to eq(original_blob)
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Replace image')
    expect(ImageFile.find(image.id).image.blob.id).to eq(replacement_blob)
    expect(ActiveStorage::Blob.exists?(original_blob)).to be(true)
    expect(ActiveStorage::Attachment.where(blob_id: replacement_blob)).to exist
  end

  it 'propagates both time coordinates when reading historical associations' do
    admin = create(:user, access: 'super')
    record = create(:page)
    section = create(:section, page: record, description: '<p>Earlier section</p>')
    before_edit = Time.current
    PublishingContext.editing = true
    section.update!(description: '<p>Later section</p>')
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Change section')
    historical = Page.bitemporal_at(valid_at: before_edit, known_at: Time.current).where(id: record.id).first
    expect(historical.sections.first.description).to include('Earlier section')
  end

  it 'can render an initial historical image through its retained attachment' do
    image = create(:image_file)
    historical = ImageFile.bitemporal_at(valid_at: Time.current, known_at: Time.current).where(id: image.id).first
    expect(historical.image_url).to include('/rails/active_storage/blobs/')
    expect(historical.image.blob.id).to eq(image.image.blob.id)
  end

  it 'publishes a name exchange together after closing both old periods' do
    admin = create(:user, access: 'super')
    first = create(:page)
    second = create(:page)
    first_name, second_name = first.name, second.name
    PublishingContext.editing = true
    first.name = second_name
    first.save!(validate: false)
    second.name = first_name
    second.save!(validate: false)
    PublishingContext.editing = false
    Publishing.deploy!(actor: admin, summary: 'Exchange names')
    PublishingContext.live = true
    expect(Page.find(first.id).name).to eq(second_name)
    expect(Page.find(second.id).name).to eq(first_name)
  end

  it 'rolls back every period change if any pending member is invalid' do
    admin = create(:user, access: 'super')
    first = create(:page, title: 'Still live')
    second = create(:page)
    PublishingContext.editing = true
    first.update!(title: 'Pending title')
    second.name = ''
    second.save!(validate: false)
    PublishingContext.editing = false
    expect { Publishing.deploy!(actor: admin, summary: 'Invalid group') }.to raise_error(ActiveRecord::RecordInvalid)
    PublishingContext.live = true
    expect(Page.find(first.id).title).to eq('Still live')
    expect(Page.find(second.id)).to be_present
    expect(Deployment.count).to eq(0)
  end
end

RSpec.describe 'Recorded-time restoration' do
  self.use_transactional_tests = false

  it 'restores the selected recorded correction rather than the latest correction' do
    PublishingContext.live = false
    record = create(:page)
    begin
      PublishingContext.editing = true
      record.update!(title: 'Earlier pending correction')
      known_at = Time.current
      record = Page.find(record.id)
      record.update!(title: 'Later pending correction')
      Publishing.restore!(model: Page, id: record.id, version: record.version, recorded_at: known_at)
      expect(Page.find(record.id).title).to eq('Earlier pending correction')
    ensure
      Page.unscoped.where(id: record.id).delete_all
      Page.connection.execute("DELETE FROM pages_history WHERE id = #{Integer(record.id)}")
      Page.connection.execute("DELETE FROM pages_identities WHERE id = #{Integer(record.id)}")
      PublishingContext.reset
    end
  end
end
