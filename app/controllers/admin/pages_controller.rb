# /app/controllers/admin/pages

class Admin::PagesController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit             = 20
    @default_column         = 'name'
    @has_query              = false
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
    if (params[:canceled] == "true") && (params[:new_section] == "true") && params[:section_id].present?
      Section.find_by(id: params[:section_id])&.destroy
    end

    super
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
    section                 = page.sections.create!(content_type: page.section,
                                                    section_name: Section.generate_unique_name,
                                                    description: "New Section. Please replace this text.",
                                                    section_order: section_order)
    @new_section            = true
    @read_only_content_type = true

    redirect_to edit_admin_section_path(section,
                                        read_only_content_type: @read_only_content_type,
                                        new_section:            @new_section,
                                        return_url:             edit_admin_page_path(page, section_name: section.section_name, return_url: admin_return_url),
                                        cancel_url:             edit_admin_page_path(page, return_url: admin_return_url, new_section: true),
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
end
