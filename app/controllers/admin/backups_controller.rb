# The "Backup and restore" page: backs up the site databases and the images into the
# same files bin/backup_database.sh makes, saves them on the administrator's computer
# and restores them from there. The work itself is SiteBackup's.
class Admin::BackupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_administrator

  def show
    @title = "#{get_site_information.site_name} - Admin Dashboard: Backup and restore"
    set_title(@title)
    @databases = SiteBackup.databases
    @status = SiteBackup.status
  end

  def status
    render json: SiteBackup.status
  end

  def start
    SiteBackup.start_backup!(databases: params[:databases], images: ActiveModel::Type::Boolean.new.cast(params[:images]))
    Rails.logger.info("Backup started by #{current_user.email}")
    render json: SiteBackup.status
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  # The whole file, or with offset (and length) one piece of it. The page fetches large
  # files in pieces: a single response of a gigabyte or more is cut off when the
  # visitor's connection is slower than the server (nginx stops reading once its
  # buffer is full, and Puma gives up writing after a few seconds).
  def download
    file = SiteBackup.finished_file(params[:name])
    return head :not_found unless file

    # no-transform keeps Rack::Deflater from compressing the file again on the way out.
    response.headers["Cache-Control"] = "private, no-transform"
    response.headers["X-File-Size"] = file.size.to_s
    return send_file(file, filename: file.basename.to_s, type: "application/octet-stream", disposition: "attachment") if params[:offset].blank?

    offset = params[:offset].to_i
    length = params[:length].present? ? params[:length].to_i : SiteBackup::DOWNLOAD_PIECE_BYTES
    return head :range_not_satisfiable if offset.negative? || offset > file.size || length <= 0 || length > SiteBackup::DOWNLOAD_PIECE_BYTES

    data = File.open(file, "rb") { |source| source.seek(offset) && source.read(length) } || ""
    send_data data, type: "application/octet-stream", disposition: "attachment", filename: file.basename.to_s
  end

  def discard
    SiteBackup.discard_backup!
    render json: SiteBackup.status
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  # One part of a file being uploaded for a restore: the raw bytes in the body.
  def upload
    data = request.body.read(SiteBackup::CHUNK_BYTES + 1)
    raise SiteBackup::Error, "A part may hold at most #{SiteBackup::CHUNK_BYTES} bytes." if data.bytesize > SiteBackup::CHUNK_BYTES

    size = SiteBackup.receive_part!(name: params[:name].to_s, offset: params[:offset].to_i, data: data,
                                    last: ActiveModel::Type::Boolean.new.cast(params[:last]))
    render json: { name: params[:name], size: size }
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  def plan
    render json: { plan: SiteBackup.restore_plan(Array(params[:names]).map(&:to_s)) }
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  def restore
    raise SiteBackup::Error, "Type RESTORE to confirm." unless params[:confirm] == "RESTORE"

    Rails.logger.info("Restore started by #{current_user.email}: #{SiteBackup.restore_plan.map { |item| item['file'] }.join(', ')}")
    targets = params[:targets].respond_to?(:to_unsafe_h) ? params[:targets].to_unsafe_h : {}
    SiteBackup.start_restore!(targets: targets.transform_keys(&:to_s).transform_values(&:to_s))
    render json: SiteBackup.status
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  def discard_uploads
    SiteBackup.discard_uploads!
    render json: SiteBackup.status
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  def dismiss
    SiteBackup.clear_status!
    render json: SiteBackup.status
  rescue SiteBackup::Error => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  private

  # Only an administrator of the main site: a restore replaces every account and page.
  def require_administrator
    return head :forbidden if SiteContext.tenant?

    redirect_to root_path, alert: "Administrator access is required." unless current_user&.admin?
  end
end
