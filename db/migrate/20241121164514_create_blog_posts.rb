class CreateBlogPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.datetime :posted, default: -> { 'CURRENT_TIMESTAMP' }, null: false
      t.text :content, null: false
      t.string :visibility
      t.string :blog_type
      t.string :checksum, limit: 512

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :blog_posts, :title
    add_index :blog_posts, :author
  end
end
