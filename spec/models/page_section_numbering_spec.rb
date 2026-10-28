require "rails_helper"

RSpec.describe "Page section numbering", type: :model do
  let!(:page_record) { create(:page) }

  it "renumbers negative values, gaps, ties and unnumbered sections without changing other values" do
    last = create(:section, page: page_record, section_order: 200)
    first = create(:section, page: page_record, section_order: -30)
    tied_first = create(:section, page: page_record, section_order: 7)
    zero = create(:section, page: page_record, section_order: 0)
    tied_second = create(:section, page: page_record, section_order: 7)
    unnumbered = create(:section, page: page_record, section_order: nil)
    other = create(:section, section_order: -100)
    expected = [ first, zero, tied_first, tied_second, last, unnumbered ]
    previous = expected.to_h { |section| [ section.id, section.reload.attributes.except("section_order") ] }

    expect(page_record.ordered_sections.pluck(:id)).to eq(expected.map(&:id))
    expect(page_record.renumber_sections!).to eq(6)
    expect(page_record.ordered_sections.pluck(:id, :section_order)).to eq(
      expected.each_with_index.map { |section, index| [ section.id, (index + 1) * 10 ] }
    )
    expected.each { |section| expect(section.reload.attributes.except("section_order")).to eq(previous.fetch(section.id)) }
    expect(other.reload.section_order).to eq(-100)
  end

  it "rolls back earlier updates if a later section cannot be updated" do
    first = create(:section, page: page_record, section_order: -5)
    second = create(:section, page: page_record, section_order: 400)
    allow_any_instance_of(Section).to receive(:update_columns).and_wrap_original do |method, *args, **kwargs|
      raise ActiveRecord::RecordNotSaved, "Cannot update section" if method.receiver.id == second.id
      method.call(*args, **kwargs)
    end
    expect { page_record.renumber_sections! }.to raise_error(ActiveRecord::RecordNotSaved)
    expect([ first.reload.section_order, second.reload.section_order ]).to eq([ -5, 400 ])
  end

  it "handles an empty page" do
    expect(page_record.renumber_sections!).to eq(0)
    expect(page_record.sections).to be_empty
  end

  it "only renumbers the section group displayed by the page" do
    shown = create(:section, page: page_record, section_order: 12)
    hidden = create(:section, page: page_record, content_type: "another-group", section_order: 17)
    page_record.renumber_sections!
    expect(shown.reload.section_order).to eq(10)
    expect(hidden.reload.section_order).to eq(17)
  end
end
