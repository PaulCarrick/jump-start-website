# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :content_type, null: false
      t.string :section_name
      t.integer :section_order
      t.string :image_file
      t.string :link
      t.string :formatting
      t.text :description

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :sections,
              [ :content_type, :section_name, :section_order ],
              unique: true,
              where: "section_name IS NOT NULL AND section_order IS NOT NULL",
              name: "index_sections_on_content_type_and_name_and_order"
  end
end
