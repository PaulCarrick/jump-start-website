require 'rails_helper'

RSpec.describe 'Publishing chosen groups' do
  let(:admin) { create(:user, access: 'super') }
  let!(:garden) { create(:page, name: 'garden', section: 'garden-content', title: 'Garden') }
  let!(:kitchen) { create(:page, name: 'kitchen', section: 'kitchen-content', title: 'Kitchen') }
  let!(:garden_section) { create(:section, page: garden, content_type: 'garden-content', section_name: 'garden-one') }
  let!(:garden_cell) { create(:cell, section: garden_section, section_name: 'garden-one', content: '<p>Old roses</p>', image: nil, link: nil) }
  let!(:menu_item) { create(:menu_item, menu_type: 'Main', label: 'Blog', link: '/blog') }

  after { PublishingContext.reset }

  def live(model, id)
    model.live_versions.find_by(id: id)
  end

  def editing
    PublishingContext.editing = true
    yield
  ensure
    PublishingContext.editing = false
  end

  def groups
    PublishingReview.groups.index_by(&:title)
  end

  def drafts_of(*titles)
    titles.flat_map { |title| groups.fetch(title).changes.map { |change| [ change.record.class.name, change.record.id ] } }
  end

  it 'groups a page with its new section, its columns and its menu entry' do
    editing do
      garden.update!(title: 'Our Garden')
      new_section = create(:section, page: garden, content_type: 'garden-content', section_name: 'garden-two')
      create(:cell, section: new_section, section_name: 'garden-two', content: '<p>Tulips</p>', image: nil, link: nil)
      garden_cell.update!(content: '<p>New roses</p>')
      create(:menu_item, menu_type: 'Main', label: 'Garden', link: '/garden', page_id: garden.id)
      menu_item.update!(label: 'Posts')
      kitchen.update!(title: 'Our Kitchen')
    end

    expect(groups.keys).to eq([ 'Our Garden', 'Our Kitchen', 'Header menu' ])
    garden_group = groups.fetch('Our Garden')
    expect(garden_group.changes.map(&:label)).to eq([
      'Page settings', 'Section garden-two', 'Column: New roses', 'Column: Tulips', 'Menu item "Garden"'
    ])
    page_change = garden_group.changes.first
    expect(page_change.kind).to eq('Changed')
    expect(page_change.fields.map { |field| [ field.name, field.before, field.after ] }).to eq([ [ 'Title', 'Garden', 'Our Garden' ] ])
    expect(groups.fetch('Header menu').changes.first.fields.first.after).to eq('Posts')
  end

  it 'publishes only the chosen groups and leaves the rest as drafts' do
    editing do
      garden.update!(title: 'Our Garden')
      garden_cell.update!(content: '<p>New roses</p>')
      kitchen.update!(title: 'Our Kitchen')
      menu_item.update!(label: 'Posts')
    end

    Publishing.deploy!(actor: admin, summary: '', only: drafts_of('Our Garden'), contents: 'Our Garden (2 changes)')

    expect(live(Page, garden.id).title).to eq('Our Garden')
    expect(live(Cell, garden_cell.id).content).to include('New roses')
    expect(live(Page, kitchen.id).title).to eq('Kitchen')
    expect(live(MenuItem, menu_item.id).label).to eq('Blog')
    expect(Publishing.pending.map { |record| record.class.name }.sort).to eq(%w[MenuItem Page])
    expect(Deployment.last.contents).to eq('Our Garden (2 changes)')
  end

  it 'publishes a new section together with its columns' do
    new_section = nil
    editing do
      new_section = create(:section, page: garden, content_type: 'garden-content', section_name: 'garden-two')
      create(:cell, section: new_section, section_name: 'garden-two', content: '<p>Tulips</p>', image: nil, link: nil)
      kitchen.update!(title: 'Our Kitchen')
    end

    Publishing.deploy!(actor: admin, summary: '', only: drafts_of('Garden'))

    expect(live(Section, new_section.id)).to be_present
    expect(Cell.live_versions.where(section_id: new_section.id).count).to eq(1)
    expect(Publishing.pending.map { |record| record.class.name }).to eq(%w[Page])
  end

  it 'refuses, and publishes nothing, when a chosen column needs a section that stays a draft' do
    new_section = nil
    cell = nil
    editing do
      new_section = create(:section, page: garden, content_type: 'garden-content', section_name: 'garden-two')
      cell = create(:cell, section: new_section, section_name: 'garden-two', content: '<p>Tulips</p>', image: nil, link: nil)
    end

    expect { Publishing.deploy!(actor: admin, summary: '', only: [ [ 'Cell', cell.id ] ]) }
      .to raise_error(Publishing::Conflict, /unpublished section/)
    expect(live(Cell, cell.id)).to be_nil
    expect(Publishing.pending.size).to eq(2)
  end

  it 'discards only the chosen groups' do
    editing do
      garden.update!(title: 'Our Garden')
      kitchen.update!(title: 'Our Kitchen')
    end

    Publishing.discard!(only: drafts_of('Our Kitchen'))

    expect(Publishing.pending.map(&:id)).to eq([ garden.id ])
    PublishingContext.live = false
    expect(Page.find(kitchen.id).title).to eq('Kitchen')
  end

  it 'still publishes everything when no groups are given' do
    editing do
      garden.update!(title: 'Our Garden')
      kitchen.update!(title: 'Our Kitchen')
    end

    Publishing.deploy!(actor: admin, summary: 'All at once')

    expect(Publishing.pending).to be_empty
    expect(live(Page, kitchen.id).title).to eq('Our Kitchen')
  end
end
