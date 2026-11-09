module ApplicationHelper
  # Users whose access lets them open the admin area (regular users are sent back).
  ADMIN_AREA_ACCESS = %w[read_only blogs admin super].freeze

  # Header and footer items this visitor should not see: items marked for
  # administrators, and links into the admin area for anyone who cannot use it.
  def hidden_navigation_item?(item)
    return true if item.access == 'admin' && !controller.current_user_is_admin?

    item.link.to_s.strip.start_with?('/admin') && !(user_signed_in? && ADMIN_AREA_ACCESS.include?(current_user.access))
  end

  # Whether this administrator is editing this page from the public site.
  def page_editing_session?(page)
    value = session[:page_editing]
    value.is_a?(Hash) && value["page_id"].to_i == page.id
  end

  # Links into the admin open in a new tab, so the site stays open beside it.
  def navigation_target(item)
    link = item.respond_to?(:link) ? item.link : item[:link]
    link.to_s.strip.start_with?("/admin") ? "_blank" : "_self"
  end

  # A "Login" item becomes "Log out" for someone who is signed in. The
  # controller does this for top-level items; sub-items are loaded in the view.
  def with_sign_out_link(item)
    if user_signed_in? && item.link.to_s.strip == '/users/sign_in'
      item.label = 'Log out'
      item.icon  = '/images/no-keys.svg'
      item.link  = '/users/sign_out'
    end
    item
  end

  def navigation_label(item)
    label = item.label.to_s
    return label unless item.link.to_s.match?(%r{\A/(?:admin/)?cells(?:[/?#|]|\z)})

    label.gsub(/\bcells?\b/i) do |word|
      replacement = word.downcase == 'cells' ? 'columns' : 'column'
      word == word.upcase ? replacement.upcase : word[0] == word[0].upcase ? replacement.capitalize : replacement
    end
  end

  def site_local_path(value)
    return value unless value.is_a?(String) && value.start_with?('/') && !value.start_with?('//')
    mount = request.script_name.to_s
    return value if mount.empty? || value == mount || value.start_with?("#{mount}/") || value.match?(%r{\A/(assets|images|packs)/})
    mount + value
  end

  def sortable_column(display_name, column, model_path_name, custom_class: "btn btn-secondary")
    # Determine the current sort direction for the column
    current_direction = (params[:sort] == column && params[:direction] == "asc") ? "desc" : "asc"

    # Choose the arrow based on the current direction
    arrow = if params[:sort] == column
              params[:direction] == "asc" ? "↓" : "↑"
            else
              "↓↑"
            end

    # Generate the dynamic path helper (e.g., admin_blog_posts_path)
    path_helper = "admin_#{model_path_name}_path"
    path        = send(path_helper, sort: column, direction: current_direction)

    # Generate the sortable link with the arrow
    link_to "#{display_name} #{arrow}".html_safe, path, class: "#{custom_class} admin-sort-button", target: "_self"
  end

  def column_heading(label)
    content_tag(:span, label, class: "btn btn-secondary admin-column-heading")
  end

  def action_links(resource, show_path, edit_path, delete_path = nil)
    delete_path ||= resource
    links       = [
      link_to("View",
              show_path,
              class: "btn btn-secondary",
              accesskey: "v",
              target: "_self"),
      link_to("Edit",
              edit_path,
              class: "btn btn-primary",
              accesskey: "e",
              target: "_self")
    ]

    if @application_user.admin?
      links << delete_button("Delete", delete_path)
    end

    content_tag(:div, class: "admin-record-actions d-flex justify-content-end flex-wrap gap-2") { safe_join(links) }
  end

  # A real DELETE request with the security token, after a confirmation.
  # (A plain link would let another website delete things through an admin's browser.)
  def delete_button(label, path, form_id: nil)
    button_to(label, path,
              method:  :delete,
              class:   "btn btn-danger",
              form:    { class: "d-inline", id: form_id, data: { turbo: false } },
              onclick: "return confirm('Are you sure you want to delete this?');")
  end
end
