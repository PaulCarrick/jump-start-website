require 'rails_helper'

RSpec.describe Page, type: :model do
  include_context "debug setup"

  describe "associations" do
    it "has many sections" do
      association = described_class.reflect_on_association(:sections)
      expect(association.macro).to eq(:has_many)
      expect(association.macro).to eq(:has_many)
      expect(association.class_name).to eq("Section")
      expect(association.klass).to eq(Section)
      expect(association.foreign_key).to eq("page_id")
      expect(association.active_record_primary_key).to eq("id")
    end
  end

  describe "scopes" do
    let!(:page_1) { Page.create!(name: "Page 1", section: "Section 1") }
    let!(:page_2) { Page.create!(name: "Page 2", section: "Section 2") }
    let!(:section_1) { Section.create!(page: page_1, section_name: "first", content_type: "Section 1", section_order: 1, description: "This is a test page.") }
    let!(:section_2) { Section.create!(page: page_1, section_name: "second", content_type: "Section 1", section_order: 2, description: "This is a test page.") }

    describe ".by_page_name" do
      it "returns pages by name with associated sections ordered by section_order" do
        result = Page.by_page_name("Page 1")
        expect(result).to include(page_1)
        expect(result).not_to include(page_2)
        expect(result.first.sections).to eq([ section_1, section_2 ])
      end
    end

    describe ".by_section" do
      it "returns the page matching the given section" do
        result = Page.by_section("Section 1")
        expect(result).to include(page_1)
        expect(result).not_to include(page_2)
      end

      it "limits the result to one record" do
        result = Page.by_section("Section 1")
        expect(result.size).to eq(1)
      end
    end
  end

  describe "validations" do
    it "validates presence of name" do
      page = Page.new(section: "Section 1")
      expect(page.valid?).to be false
      expect(page.errors[:name]).to include("can't be blank")
    end

    it "validates presence of section" do
      page = Page.new(name: "Page 1")
      expect(page.valid?).to be false
      expect(page.errors[:section]).to include("can't be blank")
    end

    it "is valid with a name and section" do
      page = Page.create!(name: "Page 1", section: "Section 1")
      expect(page.valid?).to be true
    end
  end

  describe "integration with sections" do
    it "associates sections correctly" do
      page = Page.create!(name: "Page 1", section: "Section 1")
      section_1 = Section.create!(page: page, section_name: "first", content_type: "Section 1", description: "Test Section 1",  section_order: 1)
      section_2 = Section.create!(page: page, section_name: "second", content_type: "Section 1", description: "Test Section 2",  section_order: 2)
      expect(page.sections).to include(section_1, section_2)
    end

    it "does not include unrelated sections" do
      page = Page.create!(name: "Page 1", section: "Section 1")
      section_1 = Section.create!(page: page, section_name: "first", content_type: "Section 1", description: "Test Section 1",  section_order: 1)
      section_2 = Section.create!(page: page, section_name: "second", content_type: "Section 1", description: "Test Section 2",  section_order: 2)
      other_page = Page.create!(name: "Unrelated", section: "other")
      unrelated_section = Section.create!(page: other_page, section_name: "unrelated", content_type: "Unrelated", description: "Unrelated Test Section",  section_order: 1)
      expect(page.sections).not_to include(unrelated_section)
    end
  end

  describe "section ordering" do
    let!(:page_record) { create(:page) }
    let!(:last) { create(:section, page: page_record, section_order: 20) }
    let!(:unnumbered) { create(:section, page: page_record, section_order: nil) }
    let!(:second) { create(:section, page: page_record, section_order: 10) }
    let!(:first) { create(:section, page: page_record, section_order: -5) }
    let!(:tied) { create(:section, page: page_record, section_order: 10) }
    let(:expected_ids) { [first.id, second.id, tied.id, last.id, unnumbered.id] }

    it "orders lazily loaded sections with stable ties and unnumbered sections last" do
      expect(Page.find(page_record.id).sections.map(&:id)).to eq(expected_ids)
    end

    it "supports reverse lookup of the last section" do
      expect(Page.find(page_record.id).sections.last).to eq(unnumbered)
    end

    it "still lists distinct section names alphabetically" do
      names = [last, unnumbered, second, first, tied].map(&:section_name).sort
      expect(Page.sections(page_record)).to eq(names)
    end

    it "preserves section ordering when sections are preloaded" do
      record = Page.preload(:sections).find(page_record.id)
      expect(record.association(:sections)).to be_loaded
      expect(record.sections.map(&:id)).to eq(expected_ids)
    end

    %i[by_id by_page_name by_section].each do |scope|
      [false, true].each do |with_cells|
        it "orders #{scope} sections #{with_cells ? 'with' : 'without'} columns" do
          if with_cells
            create(:cell, section: second, cell_order: 50)
            create(:cell, section: second, cell_order: 2)
            create(:cell, section: tied, cell_order: 1)
            create(:cell, section: first, cell_order: 99)
          end
          key = { by_id: page_record.id, by_page_name: page_record.name, by_section: page_record.section }.fetch(scope)
          record = Page.public_send(scope, key).first
          expect(record.association(:sections)).to be_loaded
          expect(record.sections.map(&:id)).to eq(expected_ids)
          if with_cells
            expect(record.sections.find { |section| section.id == second.id }.cells.map(&:cell_order)).to eq([2, 50])
          end
        end
      end
    end
  end

end
