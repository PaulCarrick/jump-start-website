require 'rails_helper'

RSpec.describe Column, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "validates presence of at least one field" do
      column = Column.new
      expect(column.valid?).to be false
      expect(column.errors[:base]).to include("At least one of image or content must be present.")
    end

    it "adds an error for invalid HTML in content" do
      column = Column.new(content: "<html><body><p>Invalid HTML")
      column.valid?
      expect(column.errors[:base]).to include("Invalid HTML in Content.")
    end

    it "does not add an error for valid HTML in content" do
      column = Column.new(content: "<html><body><p>Valid HTML</p></body></html>")
      expect(column.valid?).to be true
    end

    it "skips HTML validation if content starts with <title>" do
      column = Column.new(content: "<title>Valid Title</title>")
      expect(column.valid?).to be true
    end
  end

  describe "callbacks" do
    describe "#verify_checksum" do
      it "does not raise an error if checksum matches content" do
        column   = Column.create!(column_name:  'Test',
                                  section_name: 'Test',
                                  content:      "<html><body><p>Valid HTML</p></body></html>",
                                  formatting:   '{"key":"value"}')
        checksum = Digest::SHA256.hexdigest(column.content)
        column.update!(checksum: checksum)
        expect { column.reload }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:column_1) { Column.create!(column_name: "Test 1", section_name: "type1", content: "Column 1", column_order: 1) }
    let!(:column_2) { Column.create!(column_name: "Test 2", section_name: "type1", content: "Column 2", column_order: 2) }
    let!(:column_3) { Column.create!(column_name: "Test 3", section_name: "type2", content: "Column 3", column_order: 3) }

    describe ".by_section_name" do
      it "returns columns by content type ordered by column_order" do
        result = Column.by_section_name("type1")
        expect(result).to eq([column_1, column_2])
        expect(result).not_to include(column_3)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns ransackable attributes" do
      expect(Column.ransackable_attributes).to eq(["column_name", "section_name", "image", "link", "content"])
    end
  end

  describe ".ransackable_associations" do
    it "returns an empty array" do
      expect(Column.ransackable_associations).to eq([])
    end
  end
end
