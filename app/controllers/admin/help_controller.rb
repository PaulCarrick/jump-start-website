class Admin::HelpController < ApplicationController
  before_action :authenticate_user!
  before_action :require_help_access

  def show
    @title = "Admin Help"
  end

  private

  def require_help_access
    unless @application_user&.admin? || @application_user&.read_only?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
