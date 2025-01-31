class AddReadOnlyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :access, :string

    # Back fill existing records
    User.find_each do |user|
      if user.super
        user.update_columns(access: 'super')
      elsif user.admin
        user.update_columns(access: 'admin')
      else
        user.update_columns(access: 'regular')
      end
    end

    remove_column :users, :admin, :boolean
    remove_column :users, :super, :boolean
  end
end
