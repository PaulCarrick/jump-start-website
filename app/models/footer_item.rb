# frozen_string_literal: true

# app/models/footer_item.rb
class FooterItem < ApplicationRecord
  has_many :sub_items, class_name: "FooterItem", foreign_key: "parent_id"
  belongs_to :parent, class_name: "FooterItem", optional: true

  validates :label, presence: true
end
