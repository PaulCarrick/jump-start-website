require 'rails_helper'

# Deleting something that was never published (a new section cancelled in the
# editor, say) throws the draft away instead of leaving a deletion to publish.
RSpec.describe 'Deleting a never-published draft', type: :model do
  def editing(&block) = PublishingContext.set(editing: true, deploying: false, live: false, preview: false, &block)

  it 'removes a new section and its columns completely' do
    page_record = create(:page)
    section = cell = nil
    editing do
      section = Section.create!(page: page_record, content_type: page_record.section, section_name: 'never-published')
      cell = Cell.create!(section: section, section_name: section.section_name, cell_name: 'never-published_text', cell_type: 'text', content: '<p>x</p>')
    end
    expect(Publishing.pending.map(&:id)).to include(section.id, cell.id)
    editing { Section.find(section.id).destroy }
    expect(Section.unscoped.where(id: section.id)).not_to exist
    expect(Cell.unscoped.where(id: cell.id)).not_to exist
    expect(Publishing.pending).to be_empty
  end

  it 'still keeps a deletion of a published record as a draft' do
    section = create(:section, section_name: 'published-one')
    editing { Section.find(section.id).destroy }
    expect(Section.live_versions.find_by(id: section.id)).to be_present
    expect(Section.pending_versions.find(section.id).temporal_deleted).to be(true)
  end
end
