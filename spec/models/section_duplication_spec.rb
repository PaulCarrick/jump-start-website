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

  context "with a section group" do
    let!(:sibling) do
      section.update!(section_group: "Introduction group")
      create(:section, page: section.page, section_group: "Introduction group",
        section_name: "Details", section_order: 11)
    end
    let!(:sibling_cell) { create(:cell, section: sibling, cell_name: "Details column", content: "<p>Details</p>") }

    it "appends the copied group after all current sections, preserving content and relative order" do
      create(:section, section_group: section.section_group, section_order: 1000)
      create(:section, page: section.page, section_group: "Other group", section_order: 170)
      original_attributes = [ section.reload.attributes, sibling.reload.attributes ]
      copy = nil
      expect { copy = section.duplicate!(name: "New introduction") }
        .to change(Section, :count).by(2).and change(Cell, :count).by(3)

      copies = section.page.sections.where(section_group: "New introduction").order(:section_order)
      expect(copies.pluck(:section_name)).to eq([ "New introduction", "Details Copy" ])
      expect(copies.pluck(:section_order)).to eq([180, 190])
      expect(copy).to eq(copies.first)
      copies.zip([ section, sibling ]).each do |duplicate, original|
        ignored = %w[id created_at updated_at section_name section_group section_order]
        expect(duplicate.attributes.except(*ignored)).to eq(original.attributes.except(*ignored))
        expect(duplicate.cells.map(&:content)).to eq(original.cells.map(&:content))
        expect(duplicate.cells.pluck(:section_name)).to all(eq(duplicate.section_name))
        expect(duplicate.cells.pluck(:section_id)).to all(eq(duplicate.id))
      end
      expect([ section.reload.attributes, sibling.reload.attributes ]).to eq(original_attributes)
    end

    it "copies the same complete group when started from another member" do
      copy = nil
      expect { copy = sibling.duplicate!(name: "New details") }.to change(Section, :count).by(2)
      copies = section.page.sections.where(section_group: "New details")
      expect(copies.pluck(:section_order)).to eq([21, 31])
      expect(copies.pluck(:section_name)).to eq(["Introduction Copy", "New details"])
      expect(copy).to eq(copies.last)
    end

    it "keeps repeated copies separate from the original and previous copies" do
      section.duplicate!(name: "First group")
      expect { section.duplicate!(name: "Second group") }.to change(Section, :count).by(2)
      expect(section.page.sections.where(section_group: "Introduction group").count).to eq(2)
      expect(section.page.sections.where(section_group: "First group").count).to eq(2)
      expect(section.page.sections.where(section_group: "Second group").count).to eq(2)
      expect(section.page.sections.where(section_group: "First group").pluck(:section_order)).to eq([21, 31])
      expect(section.page.sections.where(section_group: "Second group").pluck(:section_order)).to eq([41, 51])
      expect(Cell.pluck(:cell_name).uniq.length).to eq(Cell.count)
    end

    it "duplicates a copied group without including originals" do
      first = section.duplicate!(name: "First group")
      expect { first.duplicate!(name: "Second group") }.to change(Section, :count).by(2)
    end

    it "preserves display order for out-of-order creation, ties and unnumbered members" do
      section.update!(section_order: 30)
      sibling.update!(section_order: 10)
      create(:section, page: section.page, section_group: section.section_group,
        section_name: "More details", section_order: 10)
      create(:section, page: section.page, section_group: section.section_group,
        section_name: "Unnumbered", section_order: nil)
      create(:section, page: section.page, section_order: 200)

      section.duplicate!(name: "New introduction")
      copies = section.page.sections.where(section_group: "New introduction")
      expect(copies.pluck(:section_name)).to eq(["Details Copy", "More details Copy", "New introduction", "Unnumbered Copy"])
      expect(copies.pluck(:section_order)).to eq([210, 220, 230, 240])
    end

    it "starts at ten when all current section orders are unset" do
      section.update!(section_order: nil)
      sibling.update!(section_order: nil)
      section.duplicate!(name: "New introduction")
      expect(section.page.sections.where(section_group: "New introduction").pluck(:section_order)).to eq([10, 20])
    end

    it "starts exactly ten after a negative maximum" do
      section.update!(section_order: -30)
      sibling.update!(section_order: -20)
      section.duplicate!(name: "New introduction")
      expect(section.page.sections.where(section_group: "New introduction").pluck(:section_order)).to eq([-10, 0])
    end

    it "reserves the entered name when a preceding member would otherwise generate it" do
      section.update!(section_order: 50)
      sibling.update!(section_order: 10)
      copy = section.duplicate!(name: "Details Copy")
      expect(copy.section_name).to eq("Details Copy")
      expect(section.page.sections.where(section_group: "Details Copy").pluck(:section_name)).to eq(["Details 2 Copy", "Details Copy"])
      expect(copy.section_order).to eq(70)
    end

    it "rejects an existing group name without creating a partial copy" do
      create(:section, page: section.page, section_group: "Existing group")
      expect {
        expect { section.duplicate!(name: "Existing group") }.to raise_error(ActiveRecord::RecordInvalid, /already exists/)
      }.not_to change { [ Section.count, Cell.count ] }
    end

    it "rolls back all copied sections and columns if a later member fails" do
      allow_any_instance_of(Cell).to receive(:save).and_wrap_original do |method, *args, **kwargs|
        if method.receiver.cell_name == "Details column Copy"
          method.receiver.errors.add(:base, "Cannot save group member")
          raise ActiveRecord::RecordInvalid.new(method.receiver)
        end
        method.call(*args, **kwargs)
      end
      expect {
        expect { section.duplicate!(name: "New introduction") }.to raise_error(ActiveRecord::RecordInvalid)
      }.not_to change { [ Section.count, Cell.count ] }
    end
  end

  [ "", "  " ].each do |blank_group|
    it "keeps single-section duplication for a #{blank_group.inspect} group" do
      section.update!(section_group: blank_group)
      create(:section, page: section.page, section_group: blank_group)
      expect { section.duplicate!(name: "New introduction") }.to change(Section, :count).by(1)
    end
  end
end
