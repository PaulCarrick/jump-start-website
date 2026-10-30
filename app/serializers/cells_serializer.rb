class CellsSerializer < ActiveModel::Serializer
  attributes :enabled, :created_at, :updated_at, :id, :section_name, :cell_order, :content, :image, :link, :options, :formatting, :width, :checksum
end
