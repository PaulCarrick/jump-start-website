class AddChecksumToSectionsAndBlogs < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :checksum, :string, limit: 512
    add_column :post_comments, :checksum, :string, limit: 512
  end
end
