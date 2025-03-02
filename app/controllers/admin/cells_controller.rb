# /app/controllers/admin/cells

require 'uri'

class Admin::CellsController < Admin::AbstractAdminController
  def initialize
    super

    @page_limit        = 1
    @default_column    = 'cell_order'
    @default_direction = 'desc'
    @has_query         = true
    @has_sort          = true
    @model_class       = Cell
    @section_names     = []
    @images            = []
    @groups            = []
    @videos            = []
  end

  def new
    super

    setup_options

    @return_url             = params[:return_url].present? ? params[:return_url] : admin_cells_url
    @cancel_url             = params[:cancel_url].present? ? params[:cancel_url] : admin_cells_url
    @read_only_content_type = params[:read_only_content_type].present? ? params[:read_only_content_type] : false
    @new_cell             = params[:new_cell].present? ? params[:new_cell] : false
  end

  def create
    begin
      throw "You are not permitted to change #{class_title}." unless @application_user&.admin?

      set_item(true, get_params)
      get_item&.content = Utilities.pretty_print_html(get_item&.content) if get_item&.content.present?
      get_item&.save!

      if request.headers['Content-Type'] === "application/json"
        render json: { message: 'Cell created successfully', id: get_item.id }, status: :ok
      else
        redirect_to admin_cells_path, turbo: false, notice: "Cell created successfully."
      end
    rescue => e
      if request.headers['Content-Type'] === "application/json"
        error = if e.message.present?
                  e.message
                else
                  get_item&.errors&.full_messages
                end

        render json: { error: error }, status: :unprocessable_entity
      else
        handle_error(:new, e)
      end
    end
  end

  def edit
    super

    @return_url = params[:return_url].present? ? params[:return_url] : admin_cell_url(get_item)
    @cancel_url = URI(params[:cancel_url].present? ? params[:cancel_url] : admin_cells_url)

    if params[:new_cell].present?
      @cancel_url.query = URI.encode_www_form({
                                                canceled:   true,
                                                cell_id:  get_item.id,
                                                new_cell: params[:new_cell]
                                              })
    else
      @cancel_url.query = URI.encode_www_form({ canceled: true, cell_id: get_item.id })
    end

    @read_only_content_type = params[:read_only_content_type].present? ? params[:read_only_content_type] : false
    @new_cell             = params[:new_cell].present? ? params[:new_cell] : false
    @cancel_url             = @cancel_url.to_s
    get_item&.content       = Utilities.pretty_print_html(get_item&.content) if get_item&.content.present?

    setup_options
  end

  def update
    @error_message = nil
    data           = get_params
    data[:content] = Utilities.pretty_print_html(data[:content]) if data[:content].present?

    begin
      throw "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_item

      get_record&.update!(get_params)

      if request.headers['Content-Type'] === "application/json"
        render json: { message: 'Cell updated successfully' }, status: :ok
      else
        redirect_to admin_cells_path, turbo: false, notice: "Cell updated successfully."
      end
    rescue => e
      if request.headers['Content-Type'] === "application/json"
        render json: { error: get_record&.errors&.full_messages }, status: :unprocessable_entity
      else
        handle_error(:edit, e)
      end
    end
  end

  def show
    if params[:method] == "delete"
      destroy

      return
    end

    super
  end

  def destroy
    begin
      throw "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_item

      result = get_record&.destroy

      if result.destroyed?
        flash[:notice] = "#{controller_name.singularize.titleize} deleted successfully."

        if params[:return_url].present?
          redirect_to params[:return_url], turbo: false, target: "_self"
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

  def get_item
    record            = get_record
    record.formatting = {} if record.present? && !record.formatting.present? # Ensure formatting is present

    record
  end

  private

  def setup_options
    @section_names = Section.distinct.order(:section_name).pluck(:section_name)
    @images        = ImageFile.where.not(mime_type: "video/mp4").distinct.order(:name).pluck(:name)
    @groups        = ImageFile.distinct.order(:group).pluck(:group)
    @videos        = ImageFile.where(mime_type: "video/mp4").distinct.order(:name).pluck(:name)
  end

  def get_params
    params.require(:cell).permit(
      :cell_name,
      :section_name,
      :type,
      :cell_order,
      :content,
      :image,
      :link,
      :width,
      :checksum,
      options: {},
      formatting: {},
    )
  end
end
