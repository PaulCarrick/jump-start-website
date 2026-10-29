# frozen_string_literal: true

class AddSectionIdAndPageId < ActiveRecord::Migration[8.0]
  def up
    # === Add menu_item_id to pages ===
    add_column :menu_items, :page_id, :integer
    add_column :pages, :menu_item_id, :integer
    Page.reset_column_information

    Page.find_each do |page|
      link      = "/#{page.name}"
      menu_item = MenuItem.find_by(link: link)

      if menu_item.present?
        menu_item.update_attribute(:page_id, page.id)
        page.update_columns(menu_item_id: menu_item.id)
      else
        Rails.logger.warn "No matching menu for page #{page.name} with link #{link}"
      end
    end

    add_index :pages, :menu_item_id
    add_foreign_key :pages, :menu_items

    # === Add footer_item_id to pages ===
    add_column :footer_items, :page_id, :integer
    add_column :pages, :footer_item_id, :integer
    Page.reset_column_information

    Page.find_each do |page|
      link        = "/#{page.name}"
      footer_item = FooterItem.find_by(link: link)

      if footer_item.present?
        footer_item.update_attribute(:page_id, page.id)
        page.update_columns(footer_item_id: footer_item.id)
      else
        Rails.logger.warn "No matching footer for page #{page.name} with link #{link}"
      end
    end

    add_index :pages, :footer_item_id
    add_foreign_key :pages, :footer_items

    # === Add section_id to cells ===
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

    # === Add page_id to sections ===
    add_column :sections, :page_id, :integer
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

    # === Add uniqueness constraints) ===
    if Page.group(:name).having("count(*) > 1").any?
      Rails.logger.warn "Duplicate page names found, cannot add unique index on pages.name"
    else
      add_index :pages, :name, unique: true
    end

    if Page.group(:section).having("count(*) > 1").any?
      Rails.logger.warn "Duplicate page sections found, cannot add unique index on pages.section"
    else
      add_index :pages, :section, unique: true
    end
  end

  def down
    remove_foreign_key :pages, :menu_items
    remove_foreign_key :pages, :footer_items
    remove_index :pages, :menu_item_id
    remove_column :menu_items, :page_id
    remove_column :pages, :menu_item_id
    remove_index :pages, :footer_item_id
    remove_column :footer_items, :page_id
    remove_column :pages, :footer_item_id
    remove_foreign_key :cells, :sections
    remove_index :cells, :section_id
    remove_column :cells, :section_id
    remove_foreign_key :sections, :pages
    remove_index :sections, :page_id
    remove_column :sections, :page_id
    change_column_null :sections, :content_type, true
    remove_index :pages, :name if index_exists?(:pages, :name)
    remove_index :pages, :section if index_exists?(:pages, :section)
  end
end
