# frozen_string_literal: true

# app/models/footer_item.rb
class FooterItem < ApplicationRecord
  include Enableable
  include BitemporalRecord
  include AdminNavigationProtection
  include SafeLink

  LABEL_LIMIT = 60
  has_many :sub_items, class_name: "FooterItem", foreign_key: "parent_id", primary_key: :id, inverse_of: :parent
  belongs_to :parent, class_name: "FooterItem", optional: true, primary_key: :id, foreign_key: :parent_id, inverse_of: :sub_items
  belongs_to :page, class_name: "Page", optional: true, primary_key: :id, foreign_key: :page_id, inverse_of: :footer_item

  scope :root_footer_items, -> { where(parent_id: nil).order(:footer_order) }

  scope :publicly_enabled, -> { enabled.left_joins(:page).where("footer_items.page_id IS NULL OR (pages.id IS NOT NULL AND pages.enabled = ?)", true) }

  validates :label, presence: true, length: { maximum: LABEL_LIMIT }
  validates :footer_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
