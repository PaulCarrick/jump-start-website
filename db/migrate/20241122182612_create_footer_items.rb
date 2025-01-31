# frozen_string_literal: true

class CreateFooterItems < ActiveRecord::Migration[8.0]
  def change
    create_table :footer_items do |t|
      t.string :label
      t.text :icon
      t.string :options
      t.string :link
      t.string :access
      t.integer :footer_order
      t.integer :parent_id

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end
  end
end
