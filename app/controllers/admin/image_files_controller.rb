# /app/controllers/admin/image_files

class Admin::ImageFilesController < Admin::AbstractAdminController
  def index
    if params[:image_picker_complete] == "true"
      render :picker_complete, layout: false
    elsif params[:image_picker_choices] == "true"
      render json: {
        images: ImageFile.images,
        videos: ImageFile.videos,
        groups: ImageFile.where.not(group: [ nil, "" ]).distinct.order(:group).pluck(:group)
      }
    else
      super
    end
  end

  def initialize
    super

    @page_limit        = 4
    @default_column    = 'id'
    @default_direction = 'desc'
    @has_query         = true
    @has_sort          = true
    @model_class       = ImageFile
    @fields            = %i[ image ] + ImageFile.column_names
                                                .map(&:to_sym)
                                                .reject { |column| [ :id, :created_at, :updated_at ].include?(column) }
  end
end
