require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  include_context "debug setup"

  describe "associations" do
    it "has many sub_items" do
      association = described_class.reflect_on_association(:sub_items)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("MenuItem")
      expect(association.options[:foreign_key]).to eq("parent_id")
    end

    it "belongs to a parent" do
      association = described_class.reflect_on_association(:parent)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("MenuItem")
      expect(association.options[:optional]).to be true
    end
  end

  describe "hierarchical relationships" do
    let!(:parent_item) { MenuItem.create!(label: "Parent Item") }
    let!(:sub_item_1) { MenuItem.create!(label: "Sub Item 1", parent: parent_item) }
    let!(:sub_item_2) { MenuItem.create!(label: "Sub Item 2", parent: parent_item) }

    it "allows a menu item to have sub_items" do
      expect(parent_item.sub_items).to include(sub_item_1, sub_item_2)
    end

    it "allows a menu item to belong to a parent" do
      expect(sub_item_1.parent).to eq(parent_item)
      expect(sub_item_2.parent).to eq(parent_item)
    end

    it "does not include unrelated items as sub_items" do
      unrelated_item = MenuItem.create!(label: "Unrelated Item")
      expect(parent_item.sub_items).not_to include(unrelated_item)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      menu_item = MenuItem.new(label: "Menu Item")
      expect(menu_item.valid?).to be true
    end

    it "is invalid without a label" do
      menu_item = MenuItem.new
      expect(menu_item.valid?).to be false
      expect(menu_item.errors[:label]).to include("can't be blank")
    end
  end
end
