# /app/controllers/admin/pages

class Admin::PagesController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit             = 20
    @default_column         = 'name'
    @has_query              = true
    @has_sort               = true
    @model_class            = Page
    @read_only_content_type = true
  end

  def show
    set_item
    live_page = Page.live_versions.where(id: get_item.id, temporal_deleted: false).first
    if live_page
      redirect_to page_path(live_page.name), status: :see_other
    else
      redirect_to admin_publishing_path, alert: 'This page has not been deployed yet.', status: :see_other
    end
  rescue StandardError => e
    handle_error(:index, e)
  end

  def test
    setup_options

    if params[:id] != "none"
      begin
        set_item
      rescue => e
        handle_error(:index, e)
      end
    end
  end

  def new
    setup_options
    super
  end

  def edit
    remove_cancelled_new_section
    super
  end

  # The page editor: outline, preview and a panel for the chosen section or
  # column (docs/admin-redesign-plan.md, stage 5). The classic editor (edit)
  # stays for anything not here yet.
  def workspace
    remove_cancelled_new_section
    set_item
    raise ActiveRecord::RecordNotFound, "Page not found." unless get_item

    get_sections
    @sections = @sections.to_a
    cells = @sections.flat_map(&:cells)
    @selected_cell = cells.find { |cell| cell.id == params[:cell].to_i } if params[:cell].present?
    @selected_section = if @selected_cell
                          @sections.find { |section| section.id == @selected_cell.section_id }
    elsif params[:section].present?
                          @sections.find { |section| section.id == params[:section].to_i }
    end
    @selected_cell.formatting = {} if @selected_cell && @selected_cell.formatting.blank?
    @section_names = @sections.map(&:section_name).compact.uniq
  rescue StandardError => e
    handle_error(:index, e)
  end

  # Takes the page's sections in their new order, each with its columns in
  # their new order: [{ id:, cells: [id, ...] }, ...]. Columns stay in their
  # own section. Only what changed is saved, as drafts.
  def reorder
    return render(json: { error: "Only administrators can change pages." }, status: :forbidden) unless @application_user&.admin?

    page = Page.find(params[:id])
    sections = page.ordered_sections.includes(:cells).to_a.index_by(&:id)
    entries = Array(params.require(:sections)).map do |entry|
      { id: entry[:id].to_i, cells: Array(entry[:cells]).map(&:to_i) }
    end
    unless entries.map { |entry| entry[:id] }.sort == sections.keys.sort &&
           entries.all? { |entry| entry[:cells].sort == sections[entry[:id]].cells.map(&:id).sort }
      return render(json: { error: "The page has changed since it was opened. Reload the page." }, status: :unprocessable_content)
    end

    changed = 0
    Page.transaction do
      entries.each_with_index do |entry, index|
        section = sections[entry[:id]]
        order = (index + 1) * 10
        if section.section_order != order
          section.update!(section_order: order)
          changed += 1
        end
        cells = section.cells.index_by(&:id)
        entry[:cells].each_with_index do |cell_id, cell_index|
          cell = cells[cell_id]
          next if cell.cell_order == cell_index + 1

          cell.update!(cell_order: cell_index + 1)
          changed += 1
        end
      end
    end
    render json: { changed: changed }
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Someone else changed this page. Reload the page and try again." }, status: :conflict
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_content
  end

  # A new, empty text column at the end of a section, opened in the panel.
  def add_column
    page = Page.find(params[:id])
    section = page.ordered_sections.find(params[:section_id])
    unless @application_user&.admin?
      redirect_to admin_page_workspace_path(page, section: section.id, **full_window_option), status: :see_other, alert: "You are not permitted to add columns."
      return
    end

    cell = section.cells.create!(section_name: section.section_name,
                                 cell_name:    Cell.generate_unique_name,
                                 cell_type:    "text",
                                 cell_order:   section.cells.maximum(:cell_order).to_i + 1,
                                 content:      "",
                                 formatting:   { "classes" => "m-3" })
    redirect_to admin_page_workspace_path(page, cell: cell.id, **full_window_option), status: :see_other, notice: "Column added. Write its text below."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_page_workspace_path(params[:id], section: params[:section_id], **full_window_option), status: :see_other,
                alert: "Could not add a column: #{e.record.errors.full_messages.to_sentence}"
  end

  def renumber_sections
    page = Page.find(params[:id])
    unless @application_user&.admin?
      redirect_to edit_admin_page_path(page, return_url: params[:return_url].present? ? admin_return_url : nil), status: :see_other,
                  alert: "You are not permitted to renumber sections."
      return
    end

    page.renumber_sections!
    redirect_to edit_admin_page_path(page, return_url: params[:return_url].present? ? admin_return_url : nil), status: :see_other,
                notice: "Sections renumbered successfully."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::StatementInvalid => e
    Rails.logger.error("Could not renumber sections: #{e.message}")
    redirect_to edit_admin_page_path(page, return_url: params[:return_url].present? ? admin_return_url : nil), status: :see_other,
                alert: "Could not renumber sections. No changes were saved."
  end

  def add_section_to_page
    page = set_item

    if page&.id.present?
      page.save!
    else
      page.create!(get_params)
    end

    unless page.name.present?
      @error_message = "You cannot add a section until Name is set."
      flash[:error]  = @error_message

      redirect_to action: new, turbo: false

      return
    end

    unless page.section.present?
      @error_message = "You cannot add a section until Section is set."
      flash[:error]  = @error_message

      redirect_to action: new, turbo: false

      return
    end

    section_order           = page.sections.maximum(:section_order).to_i + 1
    section_order           = 1 unless section_order.present?
    # No description: the section editor has no field for it, and site search
    # would show placeholder text. Search uses the section's column text instead.
    section                 = page.sections.create!(content_type: page.section,
                                                    section_name: Section.generate_unique_name,
                                                    section_order: section_order)
    @new_section            = true
    @read_only_content_type = true

    if params[:workspace].present?
      return_url = admin_page_workspace_path(page, section: section.id, **full_window_option)
      cancel_url = admin_page_workspace_path(page, new_section: true, **full_window_option)
    else
      return_url = edit_admin_page_path(page, section_name: section.section_name, return_url: admin_return_url)
      cancel_url = edit_admin_page_path(page, return_url: admin_return_url, new_section: true)
    end

    redirect_to edit_admin_section_path(section,
                                        read_only_content_type: @read_only_content_type,
                                        new_section:            @new_section,
                                        return_url:             return_url,
                                        cancel_url:             cancel_url,
                                        turbo:                  false)
  end

  def get_sections
    page         = set_item
    if page.present?
      @sections = page.ordered_sections.includes(:cells)
    else
      @sections = []
    end
  end

  private

  # Cancelling "Add Section" removes the section it just made. Because this
  # arrives as a plain link, only remove a section of this page that has never
  # been published, so a crafted link cannot delete real content.
  def remove_cancelled_new_section
    return unless params[:canceled] == "true" && params[:new_section] == "true" && params[:section_id].present?

    section = Section.find_by(id: params[:section_id], page_id: params[:id])
    never_published = section.present? && !Section.unscoped.where(id: section.id, temporal_state: "live").exists?
    section.destroy if never_published
  end

  def setup_options(page = nil)
    if page.present?
      @sections = page.sections
    else
      @sections = Section.names
    end

    @content_types        = Section.content_types
    @images               = ImageFile.images
    @groups               = ImageFile.groups
    @videos               = ImageFile.videos
    @default_page_name    = Page.generate_unique_name
    @default_section_name = Section.generate_unique_name
    @default_cell_name    = Cell.generate_unique_name
  end

  def set_item(create = false, create_params = {})
    if create
      @result = @model_class.new(create_params)

      setup_options
    else
      if params[:id] =~ /^\d+$/
        @result = @model_class.by_id(params[:id]).first
      else
        @result = @model_class.by_page_name(params[:id]).first
      end

      setup_options(@result)
    end

    instance_variable_set(get_singular_record_name, @result)
  end

  # Keeps the page workspace's full-window view ("full=1") on a redirect.
  def full_window_option
    params[:full].present? ? { full: 1 } : {}
  end

end
