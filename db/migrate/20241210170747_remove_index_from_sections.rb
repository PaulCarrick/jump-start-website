class RemoveIndexFromSections < ActiveRecord::Migration[8.0]
  def change
    remove_index :sections, name: "index_sections_on_content_type_and_name_and_order"
  end
end
