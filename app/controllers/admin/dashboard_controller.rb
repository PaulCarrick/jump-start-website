class Admin::DashboardController < ApplicationController
  before_action :authenticate_user! unless @application_user&.roles == "professional"
  before_action :require_admin # Ensure the user is an admin

  RECENT_LIMIT = 6

  def index
    flash.clear
    @pending_changes = helpers.admin_can_publish? ? Publishing.pending : []
    @page_count = Page.count
    @blog_post_count = BlogPost.count
    @image_count = ImageFile.count
    @last_deployment = Deployment.order(:id).last if helpers.admin_can_publish?
    @recently_edited = (Page.order(updated_at: :desc).limit(RECENT_LIMIT).to_a +
                        BlogPost.order(updated_at: :desc).limit(RECENT_LIMIT).to_a)
                         .sort_by(&:updated_at).reverse.first(RECENT_LIMIT)
  end

  private

  def require_admin
    unless @application_user.admin? || @application_user.read_only?
      redirect_to root_path, turbo: false, alert: "You are not authorized to access this page."
    end
  end
end
