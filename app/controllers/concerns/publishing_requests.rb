module PublishingRequests
  extend ActiveSupport::Concern
  included do
    prepend_around_action :use_publishing_context
    helper_method :publishing_draft_editor?
    rescue_from ActiveRecord::StaleObjectError do
      message = 'This record changed after you opened it. Reopen its current draft before saving again.'
      if request.media_type == 'application/json'
        render json: { errors: [ message ] }, status: :conflict
      else
        redirect_to admin_publishing_path, alert: message, status: :see_other
      end
    end
  end

  def publishing_draft_editor?
    PublishingContext.editing
  end

  private

  def expected_temporal_versions(values, model_name = nil, result = {})
    return result unless values.respond_to?(:each_pair)
    if model_name && BitemporalRecord::MODELS.include?(model_name) && values[:id].present? && values[:version].present?
      result[[ model_name, values[:id].to_i ]] = [ values[:version].to_i, values[:updated_at] ]
    end
    values.each_pair do |key, value|
      nested_model = key.to_s.delete_suffix('_attributes').singularize.classify
      if value.is_a?(Array)
        value.each { |child| expected_temporal_versions(child, nested_model, result) }
      elsif value.respond_to?(:each_pair)
        expected_temporal_versions(value, BitemporalRecord::MODELS.include?(nested_model) ? nested_model : model_name, result)
      end
    end
    # Standard Rails edit forms carry the ID in the route rather than the form.
    if model_name.nil? && params[:id].present?
      root = controller_name.classify
      fields = values[root.underscore]
      if BitemporalRecord::MODELS.include?(root) && fields.respond_to?(:[]) && fields[:version].present?
        result[[ root, params[:id].to_i ]] = [ fields[:version].to_i, fields[:updated_at] ]
      end
    end
    result
  end

  def use_publishing_context
    previous = PublishingContext.attributes
    unless User.columns_hash.key?('validity')
      if request.get? || request.head?
        yield
      else
        message = 'Publishing upgrade pending: run the database migration and restart the application before saving.'
        if request.media_type == 'application/json'
          render json: { errors: [ message ] }, status: :service_unavailable
        else
          render plain: message, status: :service_unavailable
        end
      end
      return
    end
    PublishingContext.live = true
    # Resolve authentication from the live user before entering the workspace.
    user = current_user if respond_to?(:current_user)
    if controller_path.start_with?('api/') && %w[create update destroy].include?(action_name) && !%w[blog_posts post_comments].include?(controller_name) && !user&.admin?
      render json: { errors: [ 'Administrator access is required to change content.' ] }, status: :forbidden
      return
    end
    admin_request = (controller_path.start_with?('admin/') || (controller_path.start_with?('api/') && (%w[create update destroy].include?(action_name) || params[:public_view] != 'true'))) && user&.admin?
    PublishingContext.preview = params[:preview] == 'draft' && user&.admin?
    PublishingContext.live = !admin_request
    PublishingContext.editing = admin_request && controller_name != 'publishing'
    PublishingContext.expected_versions = expected_temporal_versions(params) if PublishingContext.editing
    yield
  ensure
    PublishingContext.reset
    previous&.each { |key, value| PublishingContext.public_send("#{key}=", value) }
  end
end
