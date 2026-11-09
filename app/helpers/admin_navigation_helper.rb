# The admin's own navigation: the sidebar groups, which entry is current, and
# the number of changes waiting to be published. It is defined here rather
# than read from the "Admin" menu items, so every site gets the same menu.
module AdminNavigationHelper
  AdminLink = Struct.new(:label, :path, :controllers, keyword_init: true)

  def admin_navigation_groups
    site_links = [
      AdminLink.new(label: "Header menu", path: admin_menu_items_path, controllers: %w[menu_items]),
      AdminLink.new(label: "Footer", path: admin_footer_items_path, controllers: %w[footer_items])
    ]
    # Secondary sites share the default site's setup, so they do not edit it.
    site_links << AdminLink.new(label: "Settings", path: admin_site_setups_path, controllers: %w[site_setups]) unless SiteContext.tenant?
    site_links << AdminLink.new(label: "Users", path: admin_users_path, controllers: %w[users])

    [
      { title: nil, links: [ AdminLink.new(label: "Dashboard", path: admin_root_path, controllers: %w[dashboard]) ] },
      { title: "Content", links: [
        AdminLink.new(label: "Pages", path: admin_pages_path, controllers: %w[pages]),
        AdminLink.new(label: "Blog", path: admin_blog_posts_path, controllers: %w[blog_posts]),
        AdminLink.new(label: "Media", path: admin_image_files_path, controllers: %w[image_files])
      ] },
      { title: "Site", links: site_links },
      # Until the page editor holds them (stage 5 of docs/admin-redesign-plan.md).
      { title: "Page parts", links: [
        AdminLink.new(label: "Sections", path: admin_sections_path, controllers: %w[sections]),
        AdminLink.new(label: "Columns", path: admin_cells_path, controllers: %w[cells])
      ] }
    ]
  end

  def admin_navigation_current?(link)
    link.controllers.include?(controller_name) && controller_path.start_with?("admin/")
  end

  # Publishing is for administrators on databases with draft support.
  def admin_can_publish?
    @application_user&.admin? && User.columns_hash.key?("validity")
  end

  def admin_pending_change_count
    return 0 unless admin_can_publish?

    @admin_pending_change_count ||= Publishing.pending.size
  end

  # A readable name for a draft or a recently edited record.
  def admin_record_label(record)
    case record
    when Page then "Page: #{record.title.presence || record.name}"
    when Section then "Section #{record.section_name} (#{record.content_type})"
    when Cell then "Column #{record.cell_name}"
    when MenuItem then "Header menu: #{record.label}"
    when FooterItem then "Footer: #{record.label}"
    when BlogPost then "Blog post: #{record.title}"
    when ImageFile then "Image: #{record.name}"
    when User then "User: #{record.email}"
    when SiteSetup then "Settings: #{record.configuration_name}"
    when PostComment then "Comment: #{record.title}"
    when Contact then "Contact message from #{record.name}"
    else "#{record.class.name.titleize} #{record.id}"
    end
  end

  def admin_record_change(record)
    return "Deleted" if record.temporal_deleted?

    record.base_version.present? ? "Changed" : "New"
  end

  # Where to edit a record, or nil when it has no admin editor (comments,
  # contact messages) or has been deleted.
  def admin_record_edit_path(record)
    return if record.temporal_deleted?

    route = "edit_admin_#{record.class.model_name.singular}_path"
    respond_to?(route) ? public_send(route, record.id) : nil
  end

  # The History button for the record being edited, which the old draft
  # banner used to carry.
  def admin_record_history_path
    model = controller_name.classify
    return unless params[:id].present? && BitemporalRecord::MODELS.include?(model)

    admin_publishing_history_path(model: model, record_id: params[:id])
  end
end
