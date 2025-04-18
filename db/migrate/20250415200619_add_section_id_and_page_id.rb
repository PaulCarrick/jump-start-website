class AddSectionIdAndPageId < ActiveRecord::Migration[8.0]
  def up
    # Add Section ID to Cells
    add_column :cells, :section_id, :integer

    Cell.reset_column_information

    Cell.find_each do |cell|
      section = Section.find_by(section_name: cell.section_name)

      if section.present?
        cell.update_columns(section_id: section.id)
      else
        Rails.logger.warn "No matching section for cell #{cell.id} with section_name #{cell.section_name}"
      end
    end

    change_column_null :cells, :section_id, false

    add_index :cells, :section_id
    add_foreign_key :cells, :sections

    # Add Page ID to Sections
    add_column :sections, :page_id, :integer
    change_column_null :sections, :content_type, false

    Section.reset_column_information

    Section.find_each do |section|
      page = Page.find_by(section: section.content_type)

      if page.present?
        section.update_columns(page_id: page.id)
      else
        Rails.logger.warn "No matching page for section #{section.id} with content_type #{section.content_type}"
      end
    end

    change_column_null :sections, :page_id, false

    add_index :sections, :page_id
    add_foreign_key :sections, :pages
    add_index :pages, :name, unique: true
    add_index :pages, :section, unique: true
  end

  def down
    # Remove Section ID from Cells
    remove_foreign_key :cells, :sections
    remove_index :cells, :section_id
    remove_column :cells, :section_id

    # Remove Page ID from Sections
    remove_foreign_key :sections, :pages
    remove_index :sections, :page_id
    remove_column :sections, :page_id
    change_column_null :sections, :content_type, true
    remove_index :pages, :name
    remove_index :pages, :section
  end
end
