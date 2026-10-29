require "rails_helper"

RSpec.describe "Section duplication", type: :model do
  let!(:section) do
    create(:section, section_name: "Introduction", section_order: 7,
      row_style: "text-left", div_ratio: "60:40",
      image_attributes: { "margin_top" => "mt-2" },
      text_attributes: { "background_color" => "red" },
      formatting: { "row_style" => "text-left", "text_classes" => "col-7", "image_classes" => "col-5" })
  end
  let!(:text) do
    create(:cell, section: section, cell_name: "Introduction text", cell_type: "text",
      cell_order: 3, content: "<p>Original <strong>content</strong></p>", width: "60%",
      formatting: { "classes" => "mt-2", "styles" => "color: red" },
      options: { "nested" => { "enabled" => true } })
  end
  let!(:image) do
    create(:cell, section: section, cell_name: "Introduction image", cell_type: "image",
      cell_order: 4, width: "40%", content: nil, image: "ImageFile:shared-photo", link: "/photo")
  end

  it "copies every section and column value except identities, parent references and names" do
    source_attributes = section.reload.attributes
    source_columns = section.cells.map(&:attributes)
    copy = nil
    expect { copy = section.duplicate!(name: "New introduction") }.to change(Section, :count).by(1).and change(Cell, :count).by(2)
    expect(copy.section_name).to eq("New introduction")
    expect(copy.page).to eq(section.page)
    ignored = %w[id created_at updated_at section_name]
    expect(copy.reload.attributes.except(*ignored)).to eq(section.reload.attributes.except(*ignored))
    copy.cells.zip(section.cells).each do |child, original|
      expect(child.id).not_to eq(original.id)
      expect(child.section_id).to eq(copy.id)
      expect(child.section_name).to eq(copy.section_name)
      expect(child.cell_name).to eq("#{original.cell_name} Copy")
      fields = %w[id created_at updated_at section_id section_name cell_name]
      expect(child.attributes.except(*fields)).to eq(original.attributes.except(*fields))
    end
    expect(section.reload.attributes).to eq(source_attributes)
    expect(section.cells.map(&:attributes)).to eq(source_columns)
  end

  it "keeps copies independent when their content is edited or the section is deleted" do
    copy = section.duplicate!(name: "New introduction")
    copy.cells.first.update!(content: "<p>Changed copy</p>", formatting: { "styles" => "color: blue" })
    expect(text.reload.content).to include("Original")
    expect(text.formatting.fetch("styles")).to eq("color: red")
    copy.destroy!
    expect(section.reload.cells.pluck(:id)).to contain_exactly(text.id, image.id)
  end

  it "preserves stored values even when loading a section derives display defaults" do
    section.update!(row_style: nil)
    copy = section.duplicate!(name: "New introduction")
    expect(Section.where(id: copy.id).pick(:row_style)).to be_nil
    expect(Section.where(id: section.id).pick(:row_style)).to be_nil
  end

  it "keeps child names unique across repeated copies" do
    create(:section, section_name: "Introduction Copy")
    create(:cell, cell_name: "Introduction text Copy")
    first = section.duplicate!(name: "First introduction")
    second = section.duplicate!(name: "Second introduction")
    expect(first.section_name).to eq("First introduction")
    expect(second.section_name).to eq("Second introduction")
    expect(first.cells.first.cell_name).to eq("Introduction text 2 Copy")
    expect(second.cells.first.cell_name).to eq("Introduction text 3 Copy")
  end

  it "rolls back the section and earlier columns when saving a later child fails" do
    allow_any_instance_of(Cell).to receive(:save).and_wrap_original do |method, *args, **kwargs|
      if method.receiver.cell_name == "Introduction image Copy"
        method.receiver.errors.add(:base, "Cannot save copied image")
        raise ActiveRecord::RecordInvalid.new(method.receiver)
      end
      method.call(*args, **kwargs)
    end
    expect {
      expect { section.duplicate!(name: "New introduction") }.to raise_error(ActiveRecord::RecordInvalid)
    }.not_to change { [ Section.count, Cell.count ] }
  end
end
