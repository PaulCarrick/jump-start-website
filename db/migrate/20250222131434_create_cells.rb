class CreateCells < ActiveRecord::Migration[8.0]
  def up
    create_table :cells do |table|
      table.string :cell_name, null: false
      table.string :section_name, null: false
      table.string :cell_type
      table.integer :cell_order
      table.text :content
      table.jsonb :options
      table.string :image
      table.string :link
      table.jsonb :formatting
      table.string :width
      table.text :checksum

      table.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :cells, [ :cell_name, :section_name ], unique: true

    # Older section records did not require names. Assign stable unique names
    # before enforcing the new constraint, preserving all content and IDs.
    connection.select_all("SELECT id FROM sections WHERE section_name IS NULL OR btrim(section_name) = '' ORDER BY id").each do |row|
      base = "legacy-section-#{row['id']}"
      name = base
      suffix = 0
      while connection.select_value("SELECT 1 FROM sections WHERE section_name = #{connection.quote(name)} LIMIT 1")
        suffix += 1
        name = "#{base}-#{suffix}"
      end
      execute "UPDATE sections SET section_name = #{connection.quote(name)} WHERE id = #{connection.quote(row['id'])}"
    end
    change_column :sections, :section_name, :string, null: false
    add_index :sections, :section_name, unique: true
  end

  def down
    change_column :sections, :section_name, :string, null: false
    remove_index :sections, :section_name
    remove_index :cells, column: [ :cell_name, :section_name ]
    drop_table :cells
  end
end
