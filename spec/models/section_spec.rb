require 'rails_helper'

RSpec.describe Section, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "requires a page" do
      section = build(:section, page: nil)
      expect(section).not_to be_valid
      expect(section.errors[:page]).to include("must exist")
    end

    it "requires a section name" do
      section = build(:section, section_name: nil)
      expect(section).not_to be_valid
      expect(section.errors[:section_name]).to include("can't be blank")
    end

    it "allows multiple sections to share a group" do
      first = create(:section, section_group: "Introduction")
      second = create(:section, section_group: "Introduction")
      expect(Section.where(section_group: "Introduction")).to contain_exactly(first, second)
    end

    it "allows ungrouped sections" do
      expect(build(:section, section_group: nil)).to be_valid
    end

    it "accepts an empty section before columns are added" do
      section = build(:section, image: nil, link: nil, description: nil)
      expect(section.valid?).to be true
    end

    it "rejects duplicate section names" do
      existing = create(:section)
      section = build(:section, section_name: existing.section_name)
      expect(section.valid?).to be false
      expect(section.errors[:section_name]).to include("has already been taken")
    end
    end
  end

  describe "callbacks" do
    describe "#verify_checksum" do
      it "does not raise an error if checksum matches description" do
        section = create(:section, content_type: 'Test', section_name: "Test", description: "<html><body><p>Valid HTML</p></body></html>", formatting: '{"key":"value"}')
        checksum = section.send(:generate_checksum, section.description)
        section.update!(checksum: checksum)
        expect { section.reload }.not_to raise_error
        expect { section.reload }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:section_1) { create(:section, content_type: "type1", section_name: "section1", description: "Section 1", section_order: 1) }
    let!(:section_2) { create(:section, content_type: "type1", section_name: "section2", description: "Section 2", section_order: 2) }
    let!(:section_3) { create(:section, content_type: "type2", section_name: "section3", description: "Section 3", section_order: 3) }

    describe ".by_content_type" do
      it "returns sections by content type ordered by section_order" do
        result = Section.by_content_type("type1")
        expect(result).to eq([ section_1, section_2 ])
        expect(result).not_to include(section_3)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns ransackable attributes" do
      expect(Section.ransackable_attributes).to eq([ "content_type", "section_name", "image", "link", "description" ])
    end
  end

  describe ".ransackable_associations" do
    it "returns an empty array" do
      expect(Section.ransackable_associations).to eq([])
    end
  end
end
