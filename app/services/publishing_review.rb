# The pending drafts in plain language, grouped the way people think of them:
# one group per page (the page's settings, its sections and columns, and the
# menu and footer entries that point at it), then the header menu, the footer,
# the blog, media, settings, users and anything else. A group is published or
# left as a whole (docs/admin-redesign-plan.md, stage 6).
class PublishingReview
  Change = Struct.new(:record, :label, :kind, :fields, keyword_init: true) do
    # "Class:id:version:saved", so a publish can check that nothing changed
    # since the review was opened (saving a draft again keeps its version).
    def token
      "#{record.class.name}:#{record.id}:#{record.version}:#{record.updated_at&.utc&.iso8601(6)}"
    end
  end

  Group = Struct.new(:key, :title, :page, :changes, keyword_init: true) do
    def tokens
      changes.map(&:token).sort
    end

    def summary
      "#{title} (#{changes.size} #{changes.size == 1 ? 'change' : 'changes'})"
    end
  end

  # One field that differs between the live version and the draft.
  Field = Struct.new(:name, :before, :after, keyword_init: true)

  OTHER_GROUPS = {
    "header" => "Header menu",
    "footer" => "Footer",
    "blog" => "Blog",
    "media" => "Media",
    "settings" => "Settings",
    "users" => "Users",
    "other" => "Sections and columns not on a page",
    "contacts" => "Contact messages"
  }.freeze
  # Fields that change with every save and say nothing to a reader.
  QUIET_FIELDS = %w[created_at updated_at checksum].freeze
  TEXT_LIMIT = 300

  def self.groups(drafts = Publishing.pending)
    new(drafts).groups
  end

  def initialize(drafts)
    @drafts = drafts
    @current = {}
  end

  def groups
    grouped = Hash.new { |hash, key| hash[key] = [] }
    pages = {}
    @drafts.each do |draft|
      key, page = group_for(draft)
      pages[key] = page if page
      grouped[key] << change_for(draft)
    end

    page_groups = grouped.keys.select { |key| key.start_with?("page:") }.map do |key|
      page = pages[key]
      Group.new(key: key, title: page.title.presence || page.name, page: page, changes: sorted(grouped[key]))
    end
    other_groups = OTHER_GROUPS.filter_map do |key, title|
      Group.new(key: key, title: title, changes: sorted(grouped[key])) if grouped.key?(key)
    end
    page_groups.sort_by { |group| group.title.downcase } + other_groups
  end

  private

  def sorted(changes)
    order = %w[Page Section Cell MenuItem FooterItem]
    changes.sort_by { |change| [ order.index(change.record.class.name) || order.size, change.label.downcase ] }
  end

  # The newest version of a record, draft or live, deleted or not.
  def current(model, id)
    return if id.nil?

    @current[[ model.name, id ]] ||= model.unscoped.where(id: id).order(version: :desc).first
  end

  def page_for_section(section)
    return if section.nil?

    current(Page, section.page_id) || Page.unscoped.where(section: section.content_type, temporal_deleted: false).order(version: :desc).first
  end

  def page_group(page)
    page ? [ "page:#{page.id}", page ] : [ "other", nil ]
  end

  def group_for(draft)
    case draft
    when Page then [ "page:#{draft.id}", draft ]
    when Section then page_group(page_for_section(draft))
    when Cell then page_group(page_for_section(current(Section, draft.section_id)))
    when MenuItem then draft.page_id && (page = current(Page, draft.page_id)) ? [ "page:#{page.id}", page ] : [ "header", nil ]
    when FooterItem then draft.page_id && (page = current(Page, draft.page_id)) ? [ "page:#{page.id}", page ] : [ "footer", nil ]
    when BlogPost, PostComment then [ "blog", nil ]
    when ImageFile then [ "media", nil ]
    when SiteSetup then [ "settings", nil ]
    when User then [ "users", nil ]
    when Contact then [ "contacts", nil ]
    else [ "other", nil ]
    end
  end

  def change_for(draft)
    live = draft.class.live_versions.find_by(id: draft.id)
    kind = if draft.temporal_deleted? then "Deleted"
    elsif live.nil? then "New"
    else "Changed"
    end
    fields = kind == "Changed" ? changed_fields(live, draft) : []
    kind = "Moved" if kind == "Changed" && fields.any? && fields.all? { |field| field.name.match?(/order|parent/i) }
    Change.new(record: draft, label: label_for(draft), kind: kind, fields: fields)
  end

  def changed_fields(live, draft)
    before = Publishing.review_attributes(live).except(*QUIET_FIELDS)
    after = Publishing.review_attributes(draft).except(*QUIET_FIELDS)
    after.filter_map do |name, value|
      next if value == before[name]

      old_text = plain(before[name])
      new_text = plain(value)
      label = draft.class.human_attribute_name(name)
      next Field.new(name: label, before: "", after: "(same words; formatting or markup changed)") if old_text == new_text

      start = changed_from(old_text, new_text)
      Field.new(name: label, before: excerpt(old_text, start), after: excerpt(new_text, start))
    end
  end

  # Long texts are shown from a little before the first difference, so the
  # change itself is visible.
  def changed_from(old_text, new_text)
    same = 0
    same += 1 while same < old_text.length && same < new_text.length && old_text[same] == new_text[same]
    same > TEXT_LIMIT / 2 ? same - 60 : 0
  end

  def excerpt(text, start)
    part = text[start, TEXT_LIMIT].to_s
    "#{'…' if start.positive?}#{part}#{'…' if text.length > start + TEXT_LIMIT}"
  end

  def plain(value)
    text = case value
           when Hash, Array then value.to_json
           when nil then ""
           else value.to_s
           end
    text = ActionView::Base.full_sanitizer.sanitize(text.gsub(/<\/?(p|div|h[1-6]|li|br)[^>]*>/i, " ")) if text.include?("<")
    text.squish
  end

  def readable(value)
    excerpt(plain(value), 0)
  end

  def label_for(draft)
    case draft
    when Page then "Page settings"
    when Section then "Section #{draft.section_name}"
    when Cell then "Column: #{cell_label(draft)}"
    when MenuItem then "Menu item \"#{draft.label}\""
    when FooterItem then "Footer item \"#{draft.label}\""
    when BlogPost then "Post \"#{draft.title}\""
    when PostComment then "Comment by #{draft.author.presence || 'a visitor'}"
    when ImageFile then "File #{draft.name}"
    when SiteSetup then "Settings for #{draft.site_name}"
    when User then "User #{draft.email}"
    when Contact then "Message from #{draft.name.presence || draft.email}"
    else "#{draft.class.model_name.human} #{draft.id}"
    end
  end

  def cell_label(cell)
    text = readable(cell.content)
    return text.length > 50 ? "#{text[0, 50]}…" : text if text.present?

    image = cell.image.to_s.sub(/\A\s*(ImageFile|ImageGroup|ImageSection):\s*/, "").delete('"').strip
    image.present? ? "image #{image}" : cell.cell_name
  end
end
