class AddChecksumToImageFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :image_files, :checksum, :string, limit: 512
  end
end
