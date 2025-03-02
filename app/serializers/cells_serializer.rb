class CellsSerializer < ActiveModel::Serializer
  attributes :id, :section_name, :cell_order, :content, :image, :link, :options, :formatting, :width, :checksum
end
