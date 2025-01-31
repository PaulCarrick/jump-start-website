class Admin::DashboardController < ApplicationController
  before_action :authenticate_user! unless @application_user&.roles == "professional"
  before_action :require_admin # Ensure the user is an admin

  def index
    flash.clear
    # Admin dashboard logic
  end

  private

  def require_admin
    unless @application_user.admin? || @application_user.read_only?
      redirect_to root_path, turbo: false, alert: "You are not authorized to access this page."
    end
  end
end
