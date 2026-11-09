# Finds the pages that show an image file. Sections and columns name images in
# their image field ("ImageFile:name", or "ImageGroup:group" for a slide show
# of a group) and videos in their text ('VideoImage:"name"').
class ImageUsage
  Usage = Struct.new(:page, :ways, keyword_init: true) do
    def label
      page ? (page.title.presence || page.name) : "Not on any page"
    end
  end

  def self.for(image_file)
    new(image_file).usages
  end

  def initialize(image_file)
    @name = image_file.name.to_s
    @group = image_file.group.to_s.strip.presence
  end

  # One entry per page, with how the page uses the image.
  def usages
    return [] if @name.blank?

    found = Hash.new { |hash, page| hash[page] = [] }
    candidates(Cell, :content).each { |cell| ways_for(cell.image, cell.content).each { |way| found[cell.section&.page] << way } }
    candidates(Section, :description).each { |section| ways_for(section.image, section.description).each { |way| found[section.page] << way } }
    found.map { |page, ways| Usage.new(page: page, ways: ways.uniq) }
         .sort_by { |usage| [ usage.page ? 0 : 1, usage.label.downcase ] }
  end

  private

  def candidates(model, text_column)
    table = model.arel_table
    terms = [ @name, @group ].compact.map { |term| "%#{ActiveRecord::Base.sanitize_sql_like(term)}%" }
    condition = terms.map { |term| table[:image].matches(term).or(table[text_column].matches(term)) }.reduce(:or)
    model.where(condition).limit(500).to_a
  end

  def ways_for(image, text)
    ways = []
    ways << "Picture" if image.to_s.match?(/\A\s*ImageFile:\s*#{Regexp.escape(@name)}\s*\z/)
    ways << "Slide show (group #{@group})" if @group && image.to_s.match?(/\A\s*ImageGroup:\s*#{Regexp.escape(@group)}\s*\z/)
    ways << "Video" if [ image, text ].any? { |value| value.to_s.match?(/VideoImage:\s*(?:"|&quot;)\s*#{Regexp.escape(@name)}\s*(?:"|&quot;)/) }
    ways
  end
end
