# /app/controllers/admin/sections

require 'uri'

class Admin::SectionsController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit        = 1
    @default_column    = 'id'
    @default_direction = 'desc'
    @has_query         = true
    @has_sort          = true
    @model_class       = Section
    @content_types     = []
    @images            = []
    @groups            = []
    @videos            = []
  end

  # A section always belongs to a page, so "New Section" from the Sections
  # list first asks which page, then uses that page's Add Section.
  def new
    if params[:page_id].present?
      page = Page.find(params[:page_id])
      redirect_to admin_add_section_to_existing_page_path(page, return_url: admin_sections_path), status: :see_other
      return
    end

    unless params[:new_section].present?
      @pages = Page.order(:title, :name)
      render :choose_page
      return
    end

    super

    setup_options

    @return_url = admin_return_url
    @cancel_url = safe_admin_return_url(params[:cancel_url]) || admin_return_url
    @read_only_content_type = params[:read_only_content_type].present? ? params[:read_only_content_type] : false
    @new_section            = params[:new_section].present? ? params[:new_section] : false
  end

  # Copies a section, or its whole group (group=1), to the end of the page,
  # under the name given (see Section#duplicate!). Answers the page workspace,
  # the classic page editor, and the page's own editing mode (JSON).
  def duplicate
    page = Page.find(params[:page_id])
    unless @application_user&.admin?
      return render(json: { error: "You are not permitted to duplicate sections." }, status: :forbidden) if request.format.json?

      redirect_to edit_admin_page_path(page, return_url: params[:return_url].present? ? admin_return_url : nil), status: :see_other, alert: "You are not permitted to duplicate sections."
      return
    end

    section = page.sections.find(params[:id])
    whole_group = params.key?(:group) ? ActiveModel::Type::Boolean.new.cast(params[:group]) : section.section_group.present?
    copies = section.duplicate!(name: params[:section_name], group: whole_group)
    message = if copies.size > 1
                "Group duplicated as #{copies.first.section_group}: #{copies.map(&:section_name).join(', ')}. They are at the end of the page."
    else
                "Section duplicated as #{copies.first.section_name}, at the end of the page."
    end
    if request.format.json?
      render json: { message: message, sections: copies.map { |copy| { id: copy.id, name: copy.section_name, group: copy.section_group } } }
    elsif params[:workspace].present?
      redirect_to admin_page_workspace_path(page, section: copies.first.id), status: :see_other, notice: message
    else
      redirect_to edit_admin_page_path(page, section_name: copies.first.section_name, return_url: params[:return_url].present? ? admin_return_url : nil),
                  status: :see_other, notice: message
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    message = e.respond_to?(:record) && e.record ? e.record.errors.full_messages.to_sentence : e.message
    if request.format.json?
      render json: { error: message }, status: :unprocessable_content
    elsif params[:workspace].present?
      redirect_to admin_page_workspace_path(page, section: params[:id]), status: :see_other, alert: "Could not duplicate: #{message}"
    else
      redirect_to edit_admin_page_path(page, return_url: params[:return_url].present? ? admin_return_url : nil), status: :see_other,
                  alert: "Could not duplicate: #{message}"
    end
  end

  # Renames a group and the sections in it, all at once (the page workspace's
  # group names form).
  def rename_group
    page = Page.find(params[:page_id])
    head(:forbidden) and return unless @application_user&.admin?

    names = params[:names].respond_to?(:to_unsafe_h) ? params[:names].to_unsafe_h : {}
    members = Section.rename_group!(page_id: page.id, group: params[:group].to_s, new_group: params[:new_group], names: names)
    redirect_to admin_page_workspace_path(page, section: params[:section_id].presence || members.first.id), status: :see_other,
                notice: "Group renamed to #{members.first.section_group}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_page_workspace_path(page, section: params[:section_id]), status: :see_other, alert: e.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_page_workspace_path(page), status: :see_other, alert: "That group is no longer on this page."
  end

  def create
    begin
      raise "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_item(true, get_params)
      get_item&.description = Utilities.pretty_print_html(get_item&.description) if get_item&.description.present?
      get_item&.save!

      if request.headers['Content-Type'] === "application/json"
        render json: { message: 'Section created successfully', id: get_item.id }, status: :ok
      else
        redirect_to admin_return_url, status: :see_other, notice: "Section created successfully."
      end
    rescue => e
      if request.headers['Content-Type'] === "application/json"
        render json: { error: get_item&.errors&.full_messages }, status: :unprocessable_entity
      else
        handle_error(:new, e)
      end
    end
  end

  def edit
    super
    @return_url = admin_return_url
    @cancel_url = URI(safe_admin_return_url(params[:cancel_url]) || admin_return_url)

    if params[:new_section] == "true"
      @cancel_url.query = URI.encode_www_form(
        URI.decode_www_form(@cancel_url.query.to_s).to_h.merge(
          canceled: true, section_id: get_item.id, new_section: true
        )
      )
    end

    @read_only_content_type = params[:read_only_content_type].present? ? params[:read_only_content_type] : false
    @new_section            = params[:new_section].present? ? params[:new_section] : false
    @cancel_url             = @cancel_url.to_s
    get_item&.description   = Utilities.pretty_print_html(get_item&.description) if get_item&.description.present?

    setup_options
  end

  def update
    @error_message     = nil
    data               = get_params
    data[:description] = Utilities.pretty_print_html(data[:description]) if data[:description].present?

    begin
      raise "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_item

      get_record&.update!(data)

      if request.headers['Content-Type'] === "application/json"
        render json: { message: 'Section updated successfully' }, status: :ok
      else
        redirect_to admin_return_url, status: :see_other, notice: "Section updated successfully."
      end
    rescue => e
      if request.headers['Content-Type'] === "application/json"
        render json: { error: get_record&.errors&.full_messages }, status: :unprocessable_entity
      else
        handle_error(:edit, e)
      end
    end
  end

  def destroy
    begin
      raise "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_item

      result = get_record&.destroy

      if result.destroyed?
        flash[:notice] = "#{controller_name.singularize.titleize} deleted successfully."

        if params[:return_url].present?
          redirect_to admin_return_url, status: :see_other
        else
          redirect_to action: :index, turbo: false
        end
      else
        raise("Could not delete #{controller_name.singularize.titleize}, ID: #{params[:id]}.")
      end
    rescue => e
      handle_error(:index, e)
    end
  end

  private

  def setup_options
    @content_types = Section.distinct.order(:content_type).pluck(:content_type)
    @images        = ImageFile.where.not(mime_type: "video/mp4").distinct.order(:name).pluck(:name)
    @groups        = ImageFile.distinct.order(:group).pluck(:group)
    @videos        = ImageFile.where(mime_type: "video/mp4").distinct.order(:name).pluck(:name)
  end

  def set_item(create = false, create_params = {})
    if create
      @result = @model_class.new(create_params)
    else
      @result = @model_class.includes(:cells).find(params[:id])
    end

    instance_variable_set(get_singular_record_name, @result)
  end

  def set_items
    @results                      = []
    @sort_column, @sort_direction = set_sorting(@default_column, @default_direction, params.deep_dup)
    @q                            = set_search(params.deep_dup)

    if @has_query && @q.present?
      if @has_sort && @sort_column.present? && @sort_direction.present?
        @results = @q.result(distinct: true)
                     .includes(:cells) # Eager load cells
                     .order("#{ActiveRecord::Base.connection.quote_column_name(@sort_column)} #{@sort_direction}")

        if @page_limit.present?
          @pagy, @results = pagy(@results, limit: @page_limit)
        else
          @pagy, @results = pagy(@results)
        end
      else
        @results = @q.result(distinct: true).includes(:cells) # Eager load cells

        if @page_limit.present?
          @pagy, @results = pagy(@results, limit: @page_limit)
        else
          @pagy, @results = pagy(@results)
        end
      end
    else
      if @sort_column.present? && @sort_direction.present?
        @pagy, @results = pagy(@model_class.includes(:cells) # Eager load cells
                                           .order("#{ActiveRecord::Base.connection.quote_column_name(@sort_column)} #{@sort_direction}"))
      else
        @pagy, @results = pagy(@model_class.includes(:cells)) # Eager load cells
      end
    end

    @results = instance_variable_set(get_plural_record_name, @results)
  end

  def get_params
    params.require(:section).permit(:enabled,
      :page_id,
      :content_type,
      :section_name,
      :section_group,
      :section_order,
      :image,
      :link,
      :description,
      :checksum,
      :row_style,
      :div_ratio,
      image_attributes: {},
      text_attributes:  {},
      formatting:       {}
    )
  end
end
