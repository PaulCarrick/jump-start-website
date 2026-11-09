# Pieces shared by the admin's lists (docs/admin-redesign-plan.md, stage 2):
# the heading with its count and New button, the search box, sortable column
# headings, status badges and the per-row actions.
module AdminListHelper
  def admin_list_heading(title, count:, new_label: nil, new_path: nil)
    content_tag(:div, class: "admin-list-heading") do
      safe_join([
        content_tag(:h1, title, class: "admin-page-title"),
        content_tag(:span, pluralize(count, "item"), class: "admin-list-count"),
        (link_to(new_label, new_path, class: "btn btn-primary admin-list-new", target: "_self") if new_label && new_path)
      ].compact)
    end
  end

  # One search box over the fields named in `predicate` (a Ransack name such as
  # "title_or_name_cont"), with Clear when a search is active.
  def admin_search_box(path, predicate, placeholder:)
    value = @q&.conditions&.find { |condition| condition.key == predicate }&.value
    form_tag(path, method: :get, class: "admin-search", role: "search", data: { turbo: false }) do
      safe_join([
        label_tag("admin-search-field", placeholder, class: "visually-hidden"),
        search_field_tag("q[#{predicate}]", value, id: "admin-search-field", placeholder: placeholder, class: "form-control"),
        submit_tag("Search", name: nil, class: "btn btn-secondary"),
        (link_to("Clear", "#{path}?clear_search=true", class: "admin-search-clear", target: "_self") if value.present?)
      ].compact)
    end
  end

  # A column heading that sorts the list, with an arrow when it is the sort.
  def admin_sort_heading(label, column, path_name)
    current = params[:sort] == column
    direction = current && params[:direction] == "asc" ? "desc" : "asc"
    arrow = current ? (params[:direction] == "asc" ? " ↑" : " ↓") : ""
    link_to("#{label}#{arrow}", send("admin_#{path_name}_path", sort: column, direction: direction),
            class: "admin-sort-link#{' is-sorted' if current}", target: "_self",
            aria: { sort: (current ? (params[:direction] == "asc" ? "ascending" : "descending") : nil) })
  end

  # Live, Draft changes, New or Hidden. Admin lists show each record's working
  # version, so a draft row is one with changes waiting to be published.
  def admin_status_badge(record)
    label, style = if record.respond_to?(:temporal_state) && record.temporal_state == "draft"
                     record.base_version.present? ? [ "Draft changes", "draft" ] : [ "New", "draft" ]
    elsif record.respond_to?(:enabled) && record.enabled == false
                     [ "Hidden", "hidden" ]
    else
                     [ "Live", "live" ]
    end
    content_tag(:span, label, class: "admin-badge admin-badge-#{style}")
  end

  # Edit, plus a ⋯ menu with View, History and (for administrators) Delete.
  def admin_row_actions(record, show_path:, edit_path:, delete_path:)
    history_path = if BitemporalRecord::MODELS.include?(record.class.name)
                     admin_publishing_history_path(model: record.class.name, record_id: record.id)
    end
    menu_items = [
      link_to("View", show_path, class: "dropdown-item", target: "_self"),
      (link_to("History", history_path, class: "dropdown-item", target: "_self") if history_path),
      (delete_button("Delete", delete_path) if @application_user&.admin?)
    ].compact

    content_tag(:div, class: "admin-row-actions") do
      safe_join([
        link_to("Edit", edit_path, class: "btn btn-sm btn-outline-primary", target: "_self"),
        content_tag(:div, class: "dropdown") do
          safe_join([
            button_tag("⋯", type: "button", class: "btn btn-sm btn-outline-secondary admin-row-menu",
                            data: { bs_toggle: "dropdown", bs_popper_config: '{"strategy":"fixed"}' }, aria: { expanded: "false", label: "More actions" }),
            content_tag(:div, safe_join(menu_items), class: "dropdown-menu dropdown-menu-end")
          ])
        end
      ])
    end
  end
end
