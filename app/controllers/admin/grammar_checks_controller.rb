# The text editor's "Check spelling and grammar" button (administrators only).
class Admin::GrammarChecksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_administrator

  def create
    render json: { problems: GrammarCheck.check(params[:text]) }
  rescue GrammarCheck::Error => error
    render json: { error: error.message }, status: :service_unavailable
  end

  private

  def require_administrator
    head :forbidden unless @application_user&.admin?
  end
end
