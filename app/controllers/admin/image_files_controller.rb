# /app/controllers/admin/image_files

class Admin::ImageFilesController < Admin::AbstractAdminController
  # What the upload area accepts: the types the image form offers.
  UPLOAD_TYPES = %w[
    image/jpeg image/png image/gif image/bmp image/webp image/svg+xml image/tiff
    image/x-icon image/vnd.microsoft.icon image/heic video/mp4
  ].freeze
  MAX_UPLOAD_FILES = 20

  def index
    if params[:image_picker_complete] == "true"
      render :picker_complete, layout: false
    elsif params[:image_picker_choices] == "true"
      render json: {
        images: ImageFile.images,
        videos: ImageFile.videos,
        groups: ImageFile.where.not(group: [ nil, "" ]).distinct.order(:group).pluck(:group),
        group_counts: ImageFile.where.not(group: [ nil, "" ]).group(:group).count
      }
    else
      super
      @group_counts = ImageFile.where.not(group: [ nil, "" ]).group(:group).order(:group).count
      @ungrouped_count = ImageFile.where(group: [ nil, "" ]).count
      @selected = ImageFile.find_by(id: params[:selected]) if params[:selected].present?
      group = @q&.conditions&.find { |condition| condition.key == "group_eq" }&.value
      @group_slides = ImageFile.where(group: group).order(ImageFile.arel_table[:slide_order].asc.nulls_last, :id).to_a if group.present?
      @usages = ImageUsage.for(@selected) if @selected
    end
  end

  # Several files at once, from the media library's upload area. Each file
  # becomes an image named after the file; a chosen group puts them at the end
  # of that group's slide show.
  def upload
    raise "You are not permitted to change #{class_title}." unless @application_user&.admin?

    files = Array(params[:files]).select { |file| file.respond_to?(:tempfile) }
    raise "Choose one or more files to upload." if files.empty?

    group = params[:group].to_s.strip.presence
    slide_order = group ? ImageFile.where(group: group).maximum(:slide_order).to_i : nil
    saved = []
    skipped = []

    files.first(MAX_UPLOAD_FILES).each do |file|
      type = Marcel::MimeType.for(file.tempfile, name: file.original_filename)
      unless UPLOAD_TYPES.include?(type)
        skipped << "#{file.original_filename} (not an image or MP4 video)"
        next
      end

      attributes = { name: unique_name(file.original_filename), image: file, mime_type: type, enabled: true }
      attributes.merge!(group: group, slide_order: slide_order += 1) if group
      saved << ImageFile.create!(attributes)
    rescue ActiveRecord::RecordInvalid => error
      skipped << "#{file.original_filename} (#{error.record.errors.full_messages.to_sentence})"
    end
    skipped << "#{files.size - MAX_UPLOAD_FILES} more (at most #{MAX_UPLOAD_FILES} at a time)" if files.size > MAX_UPLOAD_FILES

    if saved.any?
      count = saved.size == 1 ? "1 file" : "#{saved.size} files"
      flash[:notice] = "Uploaded #{count}#{" to the group #{group}" if group}."
    end
    flash[:error] = "Not uploaded: #{skipped.join('; ')}." if skipped.any?
    redirect_to admin_image_files_path(clear_search: true, selected: (saved.last.id if saved.size == 1)), status: :see_other
  rescue StandardError => error
    flash[:error] = error.message
    redirect_to admin_image_files_path, status: :see_other
  end

  # Saves the order of a group's slide show from the media library's strip of
  # pictures: params[:ids] lists every file of the group in its new order.
  # Slide numbers become 1, 2, 3 ...; only the files whose number changes are
  # saved (as drafts, like any other change).
  def group_order
    group = params[:group].to_s.strip
    ids = Array(params[:ids]).map(&:to_i)
    files = group.present? ? ImageFile.where(group: group).to_a : []
    if files.empty? || ids.uniq.size != ids.size || ids.sort != files.map(&:id).sort
      render json: { error: "The group has changed since the page was opened. Reload the page and try again." }, status: :unprocessable_content
      return
    end

    by_id = files.index_by(&:id)
    changed = 0
    ImageFile.transaction do
      ids.each_with_index do |id, index|
        file = by_id[id]
        next if file.slide_order == index + 1

        file.update!(slide_order: index + 1)
        changed += 1
      end
    end
    render json: { changed: changed }
  rescue ActiveRecord::StaleObjectError
    render json: { error: "Someone else changed this group. Reload the page and try again." }, status: :conflict
  rescue ActiveRecord::RecordInvalid => error
    render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
  end

  # Opens the media library on the image a page shows at this address (the
  # page's right-click "Edit image"). Image addresses carry their file's
  # signed id: /rails/active_storage/blobs/(redirect|proxy)/<signed id>/<name>.
  def locate
    signed_id = URI.parse(params[:src].to_s).path.to_s[%r{/rails/active_storage/blobs/(?:redirect|proxy)/([^/]+)/}, 1]
    blob = signed_id && ActiveStorage::Blob.find_signed(signed_id)
    image = if blob
              ImageFile.find_by(attachment_blob_id: blob.id) ||
                ImageFile.find_by(id: ActiveStorage::Attachment.where(blob_id: blob.id, record_type: "ImageFile").select(:record_id))
    end
    if image
      redirect_to admin_image_files_path(clear_search: true, selected: image.id), status: :see_other
    else
      redirect_to admin_image_files_path, status: :see_other, alert: "That picture is not in the media library (it may be part of the site's design)."
    end
  rescue URI::InvalidURIError
    redirect_to admin_image_files_path, status: :see_other, alert: "That picture is not in the media library."
  end

  def initialize
    super

    @page_limit        = 24
    @default_column    = 'id'
    @default_direction = 'desc'
    @has_query         = true
    @has_sort          = true
    @model_class       = ImageFile
    @fields            = %i[ image ] + ImageFile.column_names
                                                .map(&:to_sym)
                                                .reject { |column| (BitemporalRecord::META + %w[attachment_blob_id]).include?(column.to_s) }
  end

  # Showing one group lists its files in slide show order (unless a column
  # heading was chosen to sort by), so the grid matches the order strip.
  def set_items
    super
    group = @q&.conditions&.find { |condition| condition.key == "group_eq" }&.value
    return if group.blank? || params[:sort].present? || session[:image_files_sort].present?

    results = @q.result(distinct: true).reorder(ImageFile.arel_table[:slide_order].asc.nulls_last, ImageFile.arel_table[:id].asc)
    @pagy, @results = pagy(results, limit: @page_limit)
    instance_variable_set(get_plural_record_name, @results)
  end

  private

  # The file name without its extension, made unique ("photo", "photo-2" ...).
  # Pages refer to images by name, so an existing name is never reused.
  def unique_name(filename)
    base = File.basename(filename.to_s, ".*").gsub(/[^\p{L}\p{N} _.\-]/, "").squish.presence || "image"
    name = base
    number = 1
    name = "#{base}-#{number += 1}" while ImageFile.where(name: name).exists?
    name
  end
end
