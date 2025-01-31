class AddSuperToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :super, :boolean
  end
end
