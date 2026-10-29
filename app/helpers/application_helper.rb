module ApplicationHelper
  def sortable_column(display_name, column, model_path_name, custom_class: "text-dark text-decoration-none")
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
    link_to "#{display_name} #{arrow}".html_safe, path, class: custom_class, target: "_self"
  end

  def action_links(resource, show_path, edit_path, delete_path = nil)
    delete_path ||= resource
    links       = [
      link_to("View",
              show_path,
              class: "btn btn-secondary btn-sm",
              accesskey: "v",
              target: "_self"),
      link_to("Edit",
              edit_path,
              class: "btn btn-primary btn-sm",
              accesskey: "e",
              target: "_self")
    ]

    if @application_user.admin?
      links << link_to("Delete",
                       delete_path,
                       method:  :delete,
                       data:    { confirm: "Are you sure?" },
                       class:   "btn btn-danger btn-sm",
                       target:  "_self",
                       onclick: "if (!confirm('Are you sure you want to delete this?')) { return false; }")
    end

    content_tag(:div, class: "admin-record-actions d-flex justify-content-end flex-wrap gap-2 py-1") { safe_join(links) }
  end

  def quil_editor(id, value_name, classes = "", styles = "")
    render 'shared/quil_editor', locals: { id: id, value_name: value_name, classes: classes, styles: styles }
  end
end
