class AddSectionGroupToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :section_group, :string
  end
end
