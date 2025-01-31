require 'rails_helper'

RSpec.describe Section, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "validates presence of at least one field" do
      section = Section.new
      expect(section.valid?).to be false
      expect(section.errors[:base]).to include("At least one of image, link, or description must be present.")
    end

    it "adds an error for invalid HTML in description" do
      section = Section.new(description: "<html><body><p>Invalid HTML")
      section.valid?
      expect(section.errors[:base]).to include("Invalid HTML in Description.")
    end

    it "does not add an error for valid HTML in description" do
      section = Section.new(description: "<html><body><p>Valid HTML</p></body></html>")
      expect(section.valid?).to be true
    end

    it "skips HTML validation if description starts with <title>" do
      section = Section.new(description: "<title>Valid Title</title>")
      expect(section.valid?).to be true
    end
  end

  describe "callbacks" do
    describe "#verify_checksum" do
      it "does not raise an error if checksum matches description" do
        section = Section.create!(content_type: 'Test', description: "<html><body><p>Valid HTML</p></body></html>", formatting: '{"key":"value"}')
        checksum = Digest::SHA256.hexdigest(section.description)
        section.update!(checksum: checksum)
        expect { section.reload }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:section_1) { Section.create!(content_type: "type1", description: "Section 1", section_order: 1) }
    let!(:section_2) { Section.create!(content_type: "type1", description: "Section 2", section_order: 2) }
    let!(:section_3) { Section.create!(content_type: "type2", description: "Section 3", section_order: 3) }

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
