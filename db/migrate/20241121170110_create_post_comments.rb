class CreatePostComments < ActiveRecord::Migration[8.0]
  def change
    create_table :post_comments do |t|
      t.references :blog_post
      t.string :title, null: false
      t.string :author, null: false
      t.datetime :posted, default: -> { 'CURRENT_TIMESTAMP' }, null: false
      t.text :content, null: false

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :post_comments, :title
    add_index :post_comments, :author
  end
end
