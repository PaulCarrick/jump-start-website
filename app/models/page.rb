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

  # See Section#generate_unique_name for why this is based on the table's
  # own max id rather than counting currently-matching "new-page_N" names -
  # the same reissue-after-rename risk applies here.
  def self.generate_unique_name(prefix = "new-page_")
    "#{prefix}#{(Page.maximum(:id) || 0) + 1}"
  end
end
