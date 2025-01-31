class Page < ApplicationRecord
  has_many :sections,
           class_name: "Section",
           foreign_key: "content_type", # `content_type` in Section matches...
           primary_key: "section"
  scope :by_page_name, ->(name) {
    where(name: name)
      .includes(:sections)
      .references(:sections) # Ensure sections are available for ordering
      .order(:section_order) # Explicitly qualify the column with the table name
  }
  scope :by_section, ->(section) { where(section: section).limit(1) }

  validates :name, :section, presence: true
end
