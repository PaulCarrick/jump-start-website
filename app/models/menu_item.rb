# frozen_string_literal: true

# app/models/menu_item.rb
class MenuItem < ApplicationRecord
  include Enableable
  include BitemporalRecord
  include AdminNavigationProtection
  has_many :sub_items, class_name: "MenuItem", foreign_key: "parent_id", primary_key: :id, inverse_of: :parent
  belongs_to :parent, class_name: "MenuItem", optional: true, primary_key: :id, foreign_key: :parent_id, inverse_of: :sub_items
  belongs_to :page, class_name: "Page", optional: true, primary_key: :id, foreign_key: :page_id, inverse_of: :menu_item

  scope :root_main_menu_items, -> { where(menu_type: "Main", parent_id: nil).order(:menu_order) }

  scope :publicly_enabled, -> { enabled.left_joins(:page).where("menu_items.page_id IS NULL OR (pages.id IS NOT NULL AND pages.enabled = ?)", true) }

  validates :label, presence: true
end
