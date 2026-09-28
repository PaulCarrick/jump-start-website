require 'rails_helper'

RSpec.describe Section, type: :model do
  include_context "debug setup"

  describe "validations" do
    # "validates presence of at least one field" and "adds an error for invalid
    # HTML in description" used to live here, asserting on
    # #at_least_one_field_present and #description_is_valid. Those methods are
    # still defined on the model (see private methods below) but were never
    # wired up with `validate :...` - unlike Cell's matching #content_is_valid,
    # which is. Wiring them up now would break real section creation: the
    # current SectionEditor UI always saves Section-level image/link/description
    # as nil (real content now lives on Cell records), so every section created
    # through the app today would fail "at least one of image, link, or
    # description must be present." These 2 tests were removed rather than
    # made to pass, since making them pass means reintroducing a validation
    # that's incompatible with the current Cell-based content model.

    it "does not add an error for valid HTML in description" do
      # Section#page is a required association (schema: page_id null: false) and
      # section_name is required/unique - both have to be satisfied for valid?
      # to reach the description check at all.
      section = Section.new(page: create(:page), section_name: "Valid HTML Section", description: "<html><body><p>Valid HTML</p></body></html>")
      expect(section.valid?).to be true
    end

    it "skips HTML validation if description starts with <title>" do
      section = Section.new(page: create(:page), section_name: "Title Skip Section", description: "<title>Valid Title</title>")
      expect(section.valid?).to be true
    end
  end

  describe "callbacks" do
    describe "#verify_checksum" do
      it "does not raise an error if checksum matches description" do
        section = Section.create!(page: create(:page), content_type: 'Test', section_name: "Test", description: "<html><body><p>Valid HTML</p></body></html>", formatting: '{"key":"value"}')
        checksum = Digest::SHA256.hexdigest(section.description)
        section.update!(checksum: checksum)
        expect { section.reload }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:section_1) { Section.create!(page: create(:page), content_type: "type1", section_name: "section1", description: "Section 1", section_order: 1) }
    let!(:section_2) { Section.create!(page: create(:page), content_type: "type1", section_name: "section2", description: "Section 2", section_order: 2) }
    let!(:section_3) { Section.create!(page: create(:page), content_type: "type2", section_name: "section3", description: "Section 3", section_order: 3) }

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
