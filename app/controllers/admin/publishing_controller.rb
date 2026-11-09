class Admin::PublishingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_publisher

  def initialize(...)
    super

    set_title("#{get_site_information.site_name} - Admin Dashboard: Review and publish")
  end

  def index
    @pending = Publishing.pending
    @groups = PublishingReview.groups(@pending)
    @database_syncs = SiteContext.catalog? ? SiteDatabaseSyncRequest.where.not(status: 'completed').order(:id) : []
    @deployments = Deployment.order(created_at: :desc).limit(30)
    @actors = User.unscoped.where(id: @deployments.map(&:actor_id).compact.uniq).order(version: :desc).to_a.uniq(&:id).index_by(&:id)
  end

  # Publishes the groups ticked on the review page (all pending changes when
  # no groups are sent, as before). Nothing is published if the chosen groups
  # changed after the page was opened.
  def deploy
    only, groups = chosen_drafts
    contents = (groups || PublishingReview.groups).map(&:summary).join(', ')
    deployment = Publishing.deploy!(actor: current_user, summary: params[:summary].to_s.truncate(1000), only: only, contents: contents)
    sync = SiteDatabaseSyncRequest.find_by(deployment_id: deployment.id) if SiteContext.catalog?
    if sync && sync.status != 'completed'
      redirect_to admin_publishing_path, alert: "Content deployed (deployment #{deployment.id}), but site database synchronization is pending. Review the status below and retry.", status: :see_other
    else
      left = Publishing.pending.size
      notice = "Changes deployed successfully (deployment #{deployment.id}): #{contents}."
      notice += " #{left} #{left == 1 ? 'change is' : 'changes are'} still waiting." if left.positive?
      redirect_to admin_publishing_path, notice: notice.truncate(400), status: :see_other
    end
  rescue Publishing::Conflict, ActiveRecord::ActiveRecordError => e
    redirect_to admin_publishing_path, alert: publishing_error_message(e, prefix: 'Nothing was deployed'), status: :see_other
  end

  def retry_databases
    return head :forbidden if SiteContext.tenant?
    request = SiteDatabaseSyncRequest.find(params[:id])
    if request.run!
      redirect_to admin_publishing_path, notice: 'Site databases synchronized successfully.', status: :see_other
    else
      redirect_to admin_publishing_path, alert: 'Site database synchronization is still pending. See its status below.', status: :see_other
    end
  end

  def discard
    only, groups = chosen_drafts
    Publishing.discard!(only: only)
    message = groups ? "Discarded: #{groups.map(&:summary).join(', ')}. Live content is unchanged." : 'Pending changes discarded. Live content is unchanged.'
    redirect_to admin_publishing_path, notice: message.truncate(400), status: :see_other
  rescue Publishing::Conflict => e
    redirect_to admin_publishing_path, alert: publishing_error_message(e, prefix: 'Nothing was discarded'), status: :see_other
  end

  def restore
    model = Publishing.models.find { |model| model.name == params[:model] }
    raise ActiveRecord::RecordNotFound unless model
    Publishing.restore!(model: model, id: Integer(params[:record_id]), version: Integer(params[:version]), recorded_at: params[:recorded_at].presence && Time.iso8601(params[:recorded_at]))
    redirect_to admin_publishing_path, notice: 'Historical version restored as a draft. Deploy it after review.', status: :see_other
  rescue ActiveRecord::ActiveRecordError => e
    redirect_to admin_publishing_path, alert: publishing_error_message(e, prefix: 'Could not restore'), status: :see_other
  end

  def history
    model = Publishing.models.find { |model| model.name == params[:model] }
    raise ActiveRecord::RecordNotFound unless model
    @model = model
    @record_id = Integer(params[:record_id])
    @versions = model.history.where(id: @record_id).order(version: :desc, system_period: :desc).limit(100)
  end

  private

  # The drafts of the groups ticked on the review page, as [class name, id]
  # pairs, and those groups. [nil, nil] when the request names no groups
  # (publish or discard everything). Each group's changes must be exactly the
  # ones the page showed ("reviewed"), or nothing happens.
  def chosen_drafts
    return [ nil, nil ] unless params.key?(:reviewed)

    keys = Array(params[:groups]).map(&:to_s).uniq
    raise Publishing::Conflict, 'Tick at least one group.' if keys.empty?

    current = PublishingReview.groups.index_by(&:key)
    reviewed = Array(params[:reviewed]).map(&:to_s)
    groups = keys.map do |key|
      group = current[key]
      shown = reviewed.filter_map { |token| token.delete_prefix("#{key}|") if token.start_with?("#{key}|") }.sort
      raise Publishing::Conflict, 'Some changes were made after this page was opened. Review them again.' unless group && group.tokens == shown

      group
    end
    [ groups.flat_map { |group| group.changes.map { |change| [ change.record.class.name, change.record.id ] } }, groups ]
  end

  def publishing_error_message(error, prefix:)
    # SQL exception messages can contain entire content rows and exceed the
    # cookie limit. Never put SQL or record contents into the session flash.
    detail = case error
             when Publishing::Conflict then error.message.truncate(240)
             when ActiveRecord::RecordInvalid then error.record.errors.full_messages.join(', ').truncate(240)
             else 'A database error prevented this change. Your drafts are still available. Please check the application log.'
             end
    constraint = if error.cause.respond_to?(:result)
                   error.cause.result&.error_field(PG::Result::PG_DIAG_CONSTRAINT_NAME)
                 end
    Rails.logger.error("Publishing failed: #{error.class.name}; constraint=#{constraint || 'none'}")
    "#{prefix}: #{detail}"
  end

  def require_publisher
    redirect_to root_path, alert: 'Administrator access is required.' unless current_user&.admin?
  end
end
