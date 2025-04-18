class Page < ApplicationRecord
  has_many :sections, dependent: :destroy
  accepts_nested_attributes_for :sections, allow_destroy: true

  scope :by_id, ->(id) {
    where(id: id)
      .left_joins(sections: :cells)
      .includes(sections: :cells)
      .references(:sections, :cells)
      .order("sections.section_order ASC NULLS LAST, cells.cell_order ASC NULLS LAST")
      .limit(1)
  }

  scope :by_page_name, ->(name) {
    where(name: name)
      .left_joins(sections: :cells)
      .includes(sections: :cells)
      .references(:sections, :cells)
      .order("sections.section_order ASC NULLS LAST, cells.cell_order ASC NULLS LAST")
      .limit(1)
  }

  scope :by_section, ->(section) {
    where(section: section)
      .includes(sections: :cells)
      .references(:sections, :cells)
      .order("sections.section_order ASC NULLS LAST, cells.cell_order ASC NULLS LAST")
      .limit(1)
  }

  scope :sections, ->(page) { page.sections.distinct.order(:section_name).pluck(:section_name) }

  validates :name, :section, presence: true, uniqueness: true

  def self.generate_unique_name(prefix = "new-page_")
    existing_names = Page.where("name ~ ?", "^#{prefix}\\d+$").pluck(:name)

    max_number = existing_names
                   .map { |name| name[/\d+\z/].to_i }
                   .max || 0

    "#{prefix}#{max_number + 1}"
  end
end
