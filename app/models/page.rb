class Page < ApplicationRecord
  include Enableable
  has_many :sections, -> { order(Section.arel_table[:section_order].asc.nulls_last, Section.arel_table[:id].asc) }, dependent: :destroy
  accepts_nested_attributes_for :sections, allow_destroy: true
  has_one :menu_item, dependent: :destroy
  accepts_nested_attributes_for :menu_item, allow_destroy: true
  has_one :footer_item, dependent: :destroy
  accepts_nested_attributes_for :footer_item, allow_destroy: true

  scope :by_id, ->(id) {
    where(id: id)
      .preload(:menu_item, :footer_item, sections: :cells)
      .limit(1)
  }

  scope :by_page_name, ->(name) {
    where(name: name)
      .preload(:menu_item, :footer_item, sections: :cells)
      .limit(1)
  }

  scope :by_section, ->(section) {
    where(section: section)
      .preload(:menu_item, :footer_item, sections: :cells)
      .limit(1)
  }

  scope :sections, ->(page) { page.sections.distinct.reorder(:section_name).pluck(:section_name) }

  validates :name, :section, presence: true, uniqueness: true

  def ordered_sections
    return Section.none if section.blank?

    Section.where(content_type: section)
           .order(Arel.sql("sections.section_order ASC NULLS LAST, sections.id ASC"))
  end

  def renumber_sections!
    self.class.transaction do
      page = self.class.lock.find(id)
      ordered = page.ordered_sections.lock.to_a
      ordered.each_with_index do |section, index|
        unless section.update_columns(section_order: (index + 1) * 10)
          raise ActiveRecord::RecordNotSaved, "Section order could not be saved."
        end
      end
      ordered.length
    end
  end

  def self.generate_unique_name(prefix = "new-page_")
    existing_names = Page.where("name ~ ?", "^#{prefix}\\d+$").pluck(:name)

    max_number = existing_names
                   .map { |name| name[/\d+\z/].to_i }
                   .max || 0

    "#{prefix}#{max_number + 1}"
  end
end
