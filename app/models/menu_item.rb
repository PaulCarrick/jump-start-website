# frozen_string_literal: true

# app/models/menu_item.rb
class MenuItem < ApplicationRecord
  has_many :sub_items, class_name: "MenuItem", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MenuItem", optional: true
  belongs_to :page, class_name: "Page", optional: true

  scope :root_main_menu_items, -> { where(menu_type: "Main", parent_id: nil).order(:menu_order) }

  validates :label, presence: true
end
