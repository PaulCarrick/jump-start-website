# frozen_string_literal: true

# app/models/footer_item.rb
class FooterItem < ApplicationRecord
  has_many :sub_items, class_name: "FooterItem", foreign_key: "parent_id"
  belongs_to :parent, class_name: "FooterItem", optional: true
  belongs_to :page, class_name: "Page", optional: true

  scope :root_footer_items, -> { where(parent_id: nil).order(:footer_order) }

  validates :label, presence: true
end
