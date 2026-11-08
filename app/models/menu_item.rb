# frozen_string_literal: true

# app/models/menu_item.rb
class MenuItem < ApplicationRecord
  include Enableable
  include BitemporalRecord
  include AdminNavigationProtection
  include SafeLink

  MENU_TYPES  = %w[Main Admin].freeze
  LABEL_LIMIT = 60
  has_many :sub_items, -> { order(:menu_order, :id) }, class_name: "MenuItem", foreign_key: "parent_id", primary_key: :id, inverse_of: :parent
  belongs_to :parent, class_name: "MenuItem", optional: true, primary_key: :id, foreign_key: :parent_id, inverse_of: :sub_items
  belongs_to :page, class_name: "Page", optional: true, primary_key: :id, foreign_key: :page_id, inverse_of: :menu_item

  scope :root_main_menu_items, -> { where(menu_type: "Main", parent_id: nil).order(:menu_order) }

  scope :publicly_enabled, -> { enabled.left_joins(:page).where("menu_items.page_id IS NULL OR (pages.id IS NOT NULL AND pages.enabled = ?)", true) }

  validates :label, presence: true, length: { maximum: LABEL_LIMIT }
  validates :menu_type, inclusion: { in: MENU_TYPES, message: "must be Main or Admin" }, allow_blank: true
  validates :menu_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
