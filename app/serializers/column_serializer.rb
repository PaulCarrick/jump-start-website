class ColumnSerializer < ActiveModel::Serializer
  attributes :id, :section_nmme, :column_order, :description, :image, :link, :options, :formatting, :width, :checksum
end
