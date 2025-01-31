class CreateImageFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :image_files do |t|
      t.string :name, null: false
      t.string :caption
      t.string :description
      t.string :mime_type

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :image_files, :name, unique: true
  end
end
