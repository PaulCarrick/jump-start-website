# Keep navigation in the URL/form, so separate tabs do not share a return target.
module AdminReturnNavigation
  extend ActiveSupport::Concern

  included do
    before_action :prepare_admin_return_navigation
    helper_method :admin_return_url
  end

  def admin_return_url
    @admin_return_url || url_for(action: :index, only_path: true)
  end

  private

  def safe_admin_return_url(value)
    return unless value.is_a?(String)
    return if value.blank? || value.match?(/[\\\r\n]/)

    uri = URI.parse(value)
    if uri.host
      return unless uri.scheme == request.scheme && uri.host == request.host && uri.port == request.port
    else
      return if uri.scheme || !value.start_with?("/") || value.start_with?("//")
    end
    return unless uri.path == "/admin" || uri.path.start_with?("/admin/")

    route = Rails.application.routes.recognize_path(uri.path, method: :get)
    return unless route[:controller].start_with?("admin/") && %w[index show edit new].include?(route[:action])

    return if Rack::Utils.parse_nested_query(uri.query.to_s)["method"].present?

    uri.path + (uri.query ? "?#{uri.query}" : "") + (uri.fragment ? "##{uri.fragment}" : "")
  rescue URI::InvalidURIError, ActionController::RoutingError, ArgumentError
    nil
  end

  def prepare_admin_return_navigation
    @admin_return_url = safe_admin_return_url(params[:return_url])
    if @admin_return_url.nil? && %w[new edit].include?(action_name) && !params.key?(:return_url)
      caller_url = safe_admin_return_url(request.referer)
      # A reload or validation retry must not return to the editor itself.
      @admin_return_url = caller_url unless caller_url && URI.parse(caller_url).path == request.path
    end
  end
end
