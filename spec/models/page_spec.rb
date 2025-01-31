require 'rails_helper'

RSpec.describe Page, type: :model do
  include_context "debug setup"

  describe "associations" do
    it "has many sections" do
      association = described_class.reflect_on_association(:sections)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Section")
      expect(association.options[:foreign_key]).to eq("content_type")
      expect(association.options[:primary_key]).to eq("section")
    end
  end

  describe "scopes" do
    let!(:page_1) { Page.create!(name: "Page 1", section: "Section 1") }
    let!(:page_2) { Page.create!(name: "Page 2", section: "Section 2") }
    let!(:section_1) { Section.create!(content_type: "Section 1", section_order: 1, description: "This is a test page.") }
    let!(:section_2) { Section.create!(content_type: "Section 1", section_order: 2, description: "This is a test page.") }

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
        Page.create!(name: "Page 3", section: "Section 1")
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
      page = Page.new(name: "Page 1", section: "Section 1")
      expect(page.valid?).to be true
    end
  end

  describe "integration with sections" do
    it "associates sections correctly" do
      page = Page.new(name: "Page 1", section: "Section 1")
      section_1 = Section.create!(content_type: "Section 1", description: "Test Section 1",  section_order: 1)
      section_2 = Section.create!(content_type: "Section 1", description: "Test Section 2",  section_order: 2)
      expect(page.sections).to include(section_1, section_2)
    end

    it "does not include unrelated sections" do
      page = Page.new(name: "Page 1", section: "Section 1")
      section_1 = Section.create!(content_type: "Section 1", description: "Test Section 1",  section_order: 1)
      section_2 = Section.create!(content_type: "Section 1", description: "Test Section 2",  section_order: 2)
      unrelated_section = Section.create!(content_type: "Unrelated", description: "Unrelated Test Section",  section_order: 1)
      expect(page.sections).not_to include(unrelated_section)
    end
  end
end
