require 'rails_helper'

RSpec.describe Cell, type: :model do
  include_context "debug setup"

  describe "validations" do
    it "adds an error for invalid HTML in content" do
      cell = Cell.new(content: "<html><body><p>Invalid HTML")
      cell.valid?
      expect(cell.errors[:base]).to include("Invalid HTML in Content.")
    end

    it "does not add an error for valid HTML in content" do
      cell = Cell.new(cell_name: "Test", section_name: "Test", content: "<html><body><p>Valid HTML</p></body></html>")
      expect(cell.valid?).to be true
    end

    it "skips HTML validation if content starts with <title>" do
      cell = Cell.new(cell_name: "Test", section_name: "Test", content: "<title>Valid Title</title>")
      expect(cell.valid?).to be true
    end
  end

  describe "callbacks" do
    describe "#verify_checksum" do
      it "does not raise an error if checksum matches content" do
        cell     = Cell.create!(cell_name:    'Test',
                                section_name: 'Test',
                                content:      "<html><body><p>Valid HTML</p></body></html>",
                                formatting:   '{"key":"value"}')
        checksum = Digest::SHA256.hexdigest(cell.content)
        cell.update!(checksum: checksum)
        expect { cell.reload }.not_to raise_error
      end
    end
  end

  describe "scopes" do
    let!(:cell_1) { Cell.create!(cell_name: "Test 1", section_name: "type1", content: "Cell 1", cell_order: 1) }
    let!(:cell_2) { Cell.create!(cell_name: "Test 2", section_name: "type1", content: "Cell 2", cell_order: 2) }
    let!(:cell_3) { Cell.create!(cell_name: "Test 3", section_name: "type2", content: "Cell 3", cell_order: 3) }

    describe ".by_section_name" do
      it "returns cells by content type ordered by cell_order" do
        result = Cell.by_section_name("type1")
        expect(result).to eq([ cell_1, cell_2 ])
        expect(result).not_to include(cell_3)
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns ransackable attributes" do
      expect(Cell.ransackable_attributes).to eq([ "cell_name", "section_name", "image", "link", "content" ])
    end
  end

  describe ".ransackable_associations" do
    it "returns an empty array" do
      expect(Cell.ransackable_associations).to eq([])
    end
  end
end
