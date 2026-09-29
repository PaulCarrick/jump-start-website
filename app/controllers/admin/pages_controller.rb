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
      Section.delete(params[:section_id])
    end

    super
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
    # page: page is the fix - this used to create the Section without setting
    # its page at all, which always raised "Page must exist" (Section belongs_to
    # :page, required) and meant there was no working way to add a section to a
    # page anywhere in the app. content_type is kept in sync with page.section
    # for display/legacy purposes only; it is no longer used to look sections up.
    # section_name is required too (Section validates presence/uniqueness on
    # it) but was never set here at all, so this raised "Section name can't be
    # blank" on every attempt - Section.generate_unique_name is the same
    # helper already used to pick @default_section_name for the New Page form,
    # so this follows that same established pattern rather than inventing a
    # new naming scheme.
    section                 = Section.create!(page: page, content_type: page.section, section_name: Section.generate_unique_name, description: "New Section. Please replace this text.", section_order: section_order)
    @new_section            = true
    @read_only_content_type = true

    redirect_to edit_admin_section_path(section,
                                        read_only_content_type: @read_only_content_type,
                                        new_section:            @new_section,
                                        return_url:             edit_admin_page_path(page),
                                        cancel_url:             edit_admin_page_path(page, new_section: true),
                                        turbo:                  false)
  end

  def get_sections
    # Use the item the current controller action already set (get_item), not
    # set_item - calling set_item here re-derives the record from params[:id],
    # which is nil for the "new" page form (no id yet) and, on Ruby 3.2+,
    # crashes the whole view render with `NoMethodError: undefined method
    # `=~' for nil` inside set_item's `params[:id] =~ /^\d+$/` check.
    page = get_item

    # Real page_id FK association, not the legacy content_type string match -
    # every Section already has a required page_id (schema: null: false), so
    # this is both more correct and safe for existing data.
    @sections = page.present? && page.persisted? ? page.sections.includes(:cells).order(:section_order) : []
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
