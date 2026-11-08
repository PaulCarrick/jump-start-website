# Records which user wrote each comment, so only that user (or an administrator)
# may change or delete it. Comments written before this have no user and can be
# changed only by administrators.
class AddUserToPostComments < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '10s'"
    drop_versioning_hook :post_comments, :post_comments_history, primary_key: [ :id, :version ]
    %i[post_comments post_comments_history].each do |table|
      add_column table, :user_id, :bigint
    end
    add_index :post_comments, :user_id
    create_versioning_hook :post_comments, :post_comments_history, primary_key: [ :id, :version ]
  end

  def down
    execute "SET LOCAL lock_timeout = '10s'"
    drop_versioning_hook :post_comments, :post_comments_history, primary_key: [ :id, :version ]
    remove_index :post_comments, :user_id
    %i[post_comments post_comments_history].each do |table|
      remove_column table, :user_id
    end
    create_versioning_hook :post_comments, :post_comments_history, primary_key: [ :id, :version ]
  end
end
