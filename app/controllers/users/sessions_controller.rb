# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :custom_redirect, only: [ :new, :create ]

  private

  def custom_redirect
    if signed_in?
      if @application_user.admin? ||  @application_user.read_only?
        redirect_to admin_root_path, turbo: false
      else
        redirect_to root_path(data: current_user.as_json), turbo: false
      end
    end
  end
end
