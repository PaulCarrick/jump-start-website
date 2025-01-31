# frozen_string_literal: true

# app/models/menu_item.rb
class MenuItem < ApplicationRecord
  has_many :sub_items, class_name: "MenuItem", foreign_key: "parent_id"
  belongs_to :parent, class_name: "MenuItem", optional: true

  validates :label, presence: true
end
