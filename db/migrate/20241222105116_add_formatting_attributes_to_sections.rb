class AddFormattingAttributesToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :row_style, :string
    add_column :sections, :div_ratio, :string
    add_column :sections, :image_attributes, :jsonb, default: {}, null: false
    add_column :sections, :text_attributes, :jsonb, default: {}, null: false
  end
end
