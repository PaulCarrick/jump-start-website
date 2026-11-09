require "rails_helper"

# Duplicating a section, or its whole group, from the page workspace or the
# page's own editing mode. Copies go at the end of the page; a group's copies
# are named "<new group>-<old name>".
RSpec.describe "Section duplication", type: :model do
  let!(:section) do
    create(:section, section_name: "Introduction", section_order: 7,
      row_style: "text-left", div_ratio: "60:40",
      image_attributes: { "margin_top" => "mt-2" },
      text_attributes: { "background_color" => "red" },
      formatting: { "row_style" => "text-left", "text_classes" => "col-7", "image_classes" => "col-5" })
  end
  let!(:text) do
    create(:cell, section: section, cell_name: "Introduction_text", cell_type: "text",
      cell_order: 3, content: "<p>Original <strong>content</strong></p>", width: "60%",
      formatting: { "classes" => "mt-2", "styles" => "color: red" },
      options: { "nested" => { "enabled" => true } })
  end
  let!(:image) do
    create(:cell, section: section, cell_name: "Extra picture", cell_type: "image",
      cell_order: 4, width: "40%", content: nil, image: "ImageFile:shared-photo", link: "/photo")
  end

  describe "one section" do
    it "copies every value under the new name, at the end of the page, with its columns named after it" do
      create(:section, page: section.page, section_order: 40)
      source_attributes = section.reload.attributes
      copies = nil
      expect { copies = section.duplicate!(name: "New introduction") }.to change(Section, :count).by(1).and change(Cell, :count).by(2)
      copy = copies.sole
      expect(copy.section_name).to eq("New introduction")
      expect(copy.section_order).to eq(50)
      expect(copy.page).to eq(section.page)
      ignored = %w[id created_at updated_at section_name section_order]
      expect(copy.reload.attributes.except(*ignored)).to eq(section.reload.attributes.except(*ignored))
      expect(copy.cells.map(&:cell_name)).to eq([ "New introduction_text", "New introduction-Extra picture" ])
      copy.cells.zip(section.cells).each do |child, original|
        expect(child.section_id).to eq(copy.id)
        expect(child.section_name).to eq("New introduction")
        fields = %w[id created_at updated_at section_id section_name cell_name]
        expect(child.attributes.except(*fields)).to eq(original.attributes.except(*fields))
      end
      expect(section.reload.attributes).to eq(source_attributes)
    end

    it "is not put in the original's group" do
      section.update!(section_group: "intro-group")
      copy = section.duplicate!(name: "Lone copy", group: false).sole
      expect(copy.section_group).to be_nil
      expect(Section.where(section_group: "intro-group").count).to eq(1)
    end

    it "keeps copies independent of the original" do
      copy = section.duplicate!(name: "New introduction").sole
      copy.cells.first.update!(content: "<p>Changed copy</p>")
      expect(text.reload.content).to include("Original")
      copy.destroy!
      expect(section.reload.cells.pluck(:id)).to contain_exactly(text.id, image.id)
    end

    it "keeps stored values even when loading a section derives display defaults" do
      section.update!(row_style: nil)
      copy = section.duplicate!(name: "New introduction").sole
      expect(Section.where(id: copy.id).pick(:row_style)).to be_nil
    end

    it "numbers a column name that is taken" do
      create(:cell, cell_name: "Second_text")
      copy = section.duplicate!(name: "Second").sole
      expect(copy.cells.first.cell_name).to eq("Second_text-2")
    end

    it "refuses a blank, badly formed or taken name without copying anything" do
      create(:section, section_name: "Taken")
      [ [ "", /enter a name/ ], [ "bad/name", /letters, numbers/ ], [ "Taken", /already used/ ] ].each do |name, message|
        expect {
          expect { section.duplicate!(name: name) }.to raise_error(ActiveRecord::RecordInvalid, message)
        }.not_to change { [ Section.count, Cell.count ] }
      end
    end

    it "rolls back the section and earlier columns when a later column fails" do
      allow_any_instance_of(Cell).to receive(:save).and_wrap_original do |method, *args, **kwargs|
        if method.receiver.cell_name == "New introduction-Extra picture"
          method.receiver.errors.add(:base, "Cannot save copied image")
          raise ActiveRecord::RecordInvalid.new(method.receiver)
        end
        method.call(*args, **kwargs)
      end
      expect {
        expect { section.duplicate!(name: "New introduction") }.to raise_error(ActiveRecord::RecordInvalid)
      }.not_to change { [ Section.count, Cell.count ] }
    end

    [ "", "  " ].each do |blank_group|
      it "copies one section when the group is #{blank_group.inspect}" do
        section.update!(section_group: blank_group)
        create(:section, page: section.page, section_group: blank_group)
        expect { section.duplicate!(name: "New introduction") }.to change(Section, :count).by(1)
      end
    end
  end

  describe "a whole group" do
    let!(:sibling) do
      section.update!(section_group: "intro")
      create(:section, page: section.page, section_group: "intro", section_name: "Details", section_order: 11)
    end
    let!(:sibling_cell) do
      create(:cell, section: sibling, cell_name: "Details_text", content: "<p>Details</p>",
                    formatting: { "container_classes" => "expandableIntroCells pt-3" })
    end

    before do
      text.update!(formatting: { "expanding_cells" => "toggle, .expandableIntroCells, btn btn-link" })
    end

    it "names the group, puts it in front of each section's name, and adds the copies at the end in order" do
      create(:section, page: section.page, section_group: "other", section_order: 170)
      copies = nil
      expect { copies = sibling.duplicate!(name: "intro2") }.to change(Section, :count).by(2).and change(Cell, :count).by(3)
      expect(copies.map(&:section_name)).to eq(%w[intro2-Introduction intro2-Details])
      expect(copies.map(&:section_group)).to all(eq("intro2"))
      expect(copies.map(&:section_order)).to eq([ 180, 190 ])
      expect(copies.first.cells.map(&:cell_name)).to eq([ "intro2-Introduction_text", "intro2-Introduction-Extra picture" ])
      expect(copies.last.cells.map(&:cell_name)).to eq([ "intro2-Details_text" ])
      expect(copies.map { |copy| copy.cells.map(&:content) }).to eq([ section.cells.map(&:content), sibling.cells.map(&:content) ])
    end

    it "gives the copies' Show More classes of their own, so they do not open the original's" do
      copies = section.duplicate!(name: "intro2")
      expect(copies.first.cells.first.formatting["expanding_cells"]).to eq("toggle, .expandableIntroCellsIntro2, btn btn-link")
      expect(copies.last.cells.first.formatting["container_classes"]).to eq("expandableIntroCellsIntro2 pt-3")
      expect(text.reload.formatting["expanding_cells"]).to include(".expandableIntroCells,")
    end

    it "copies a copied group without the originals" do
      first = section.duplicate!(name: "first")
      expect { first.first.duplicate!(name: "second") }.to change(Section, :count).by(2)
      expect(Section.where(section_group: "second").pluck(:section_name)).to eq(%w[second-first-Introduction second-first-Details])
    end

    it "starts at ten when no section has an order, and ten after a negative one" do
      section.update!(section_order: nil)
      sibling.update!(section_order: nil)
      expect(section.duplicate!(name: "a").map(&:section_order)).to eq([ 10, 20 ])
      Section.where(section_group: "a").delete_all
      section.update!(section_order: -30)
      sibling.update!(section_order: -20)
      expect(section.duplicate!(name: "b").map(&:section_order)).to eq([ -10, 0 ])
    end

    it "refuses a group name in use on the page, or names already taken, without copying anything" do
      create(:section, page: section.page, section_group: "existing")
      create(:section, section_name: "fresh-Details")
      expect {
        expect { section.duplicate!(name: "existing") }.to raise_error(ActiveRecord::RecordInvalid, /already a group/)
        expect { section.duplicate!(name: "fresh") }.to raise_error(ActiveRecord::RecordInvalid, /fresh-Details is already used/)
      }.not_to change { [ Section.count, Cell.count ] }
    end

    it "rolls back every copy if a later one fails" do
      allow_any_instance_of(Cell).to receive(:save).and_wrap_original do |method, *args, **kwargs|
        if method.receiver.cell_name == "intro2-Details_text"
          method.receiver.errors.add(:base, "Cannot save group member")
          raise ActiveRecord::RecordInvalid.new(method.receiver)
        end
        method.call(*args, **kwargs)
      end
      expect {
        expect { section.duplicate!(name: "intro2") }.to raise_error(ActiveRecord::RecordInvalid)
      }.not_to change { [ Section.count, Cell.count ] }
    end

    it "copies only the section when asked" do
      expect { sibling.duplicate!(name: "Just details", group: false) }.to change(Section, :count).by(1)
    end
  end

  describe "renaming a group afterwards" do
    let!(:sibling) do
      section.update!(section_group: "intro")
      create(:section, page: section.page, section_group: "intro", section_name: "Details", section_order: 11)
    end

    it "renames the group and each section, and their columns follow" do
      Section.rename_group!(page_id: section.page_id, group: "intro", new_group: "welcome",
                            names: { section.id.to_s => "welcome-top", sibling.id.to_s => "welcome-more" })
      expect(section.reload.section_name).to eq("welcome-top")
      expect(sibling.reload.section_name).to eq("welcome-more")
      expect(Section.where(section_group: "welcome").count).to eq(2)
      expect(text.reload.section_name).to eq("welcome-top")
    end

    it "lets two sections swap names" do
      Section.rename_group!(page_id: section.page_id, group: "intro", new_group: "intro",
                            names: { section.id.to_s => "Details", sibling.id.to_s => "Introduction" })
      expect(section.reload.section_name).to eq("Details")
      expect(sibling.reload.section_name).to eq("Introduction")
    end

    it "refuses names in use elsewhere, repeated or badly formed, changing nothing" do
      create(:section, section_name: "Elsewhere")
      create(:section, page: section.page, section_group: "taken-group")
      [
        [ "intro", { section.id.to_s => "Elsewhere" }, /already used/ ],
        [ "intro", { section.id.to_s => "Same", sibling.id.to_s => "Same" }, /same name/ ],
        [ "taken-group", {}, /already a group/ ],
        [ "intro", { section.id.to_s => "bad/name" }, /letters, numbers/ ]
      ].each do |group, names, message|
        expect {
          Section.rename_group!(page_id: section.page_id, group: "intro", new_group: group, names: names)
        }.to raise_error(ActiveRecord::RecordInvalid, message)
      end
      expect([ section.reload.section_name, sibling.reload.section_name ]).to eq(%w[Introduction Details])
      expect(Section.where(section_group: "intro").count).to eq(2)
    end
  end
end
