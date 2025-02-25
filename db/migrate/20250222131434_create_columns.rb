class CreateColumns < ActiveRecord::Migration[8.0]
  def change
    create_table :columns do |t|
      t.string  :column_name,  null: false
      t.string  :section_name, null: false
      t.string  :column_type
      t.integer :column_order
      t.text    :content
      t.jsonb   :options
      t.string  :image
      t.string  :link
      t.jsonb   :formatting
      t.string  :width
      t.text    :checksum

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :columns, [:column_name, :section_name], unique: true

    change_column :sections, :section_name, :string, null: false
    add_index :sections, :section_name, unique: true
  end
end
