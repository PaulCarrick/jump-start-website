class AddGroupAndOrderToImageFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :image_files, :group, :string
    add_column :image_files, :slide_order, :integer
  end
end
