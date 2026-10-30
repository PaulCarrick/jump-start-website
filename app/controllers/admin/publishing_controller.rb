class Admin::PublishingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_publisher

  def index
    @pending = Publishing.pending
    @deployments = Deployment.order(created_at: :desc).limit(30)
  end

  def deploy
    deployment = Publishing.deploy!(actor: current_user, summary: params[:summary].to_s.truncate(1000))
    redirect_to admin_publishing_path, notice: "Changes deployed successfully (deployment #{deployment.id}).", status: :see_other
  rescue Publishing::Conflict, ActiveRecord::ActiveRecordError => e
    redirect_to admin_publishing_path, alert: publishing_error_message(e, prefix: 'Nothing was deployed'), status: :see_other
  end

  def discard
    Publishing.discard!
    redirect_to admin_publishing_path, notice: 'Pending changes discarded. Live content is unchanged.', status: :see_other
  end

  def restore
    model = BitemporalRecord::MODELS.find { |name| name == params[:model] }&.constantize
    raise ActiveRecord::RecordNotFound unless model
    Publishing.restore!(model: model, id: Integer(params[:record_id]), version: Integer(params[:version]), recorded_at: params[:recorded_at].presence && Time.iso8601(params[:recorded_at]))
    redirect_to admin_publishing_path, notice: 'Historical version restored as a draft. Deploy it after review.', status: :see_other
  rescue ActiveRecord::ActiveRecordError => e
    redirect_to admin_publishing_path, alert: publishing_error_message(e, prefix: 'Could not restore'), status: :see_other
  end

  def history
    model = BitemporalRecord::MODELS.find { |name| name == params[:model] }&.constantize
    raise ActiveRecord::RecordNotFound unless model
    @model = model
    @record_id = Integer(params[:record_id])
    @versions = model.history.where(id: @record_id).order(version: :desc, system_period: :desc).limit(100)
  end

  private

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
