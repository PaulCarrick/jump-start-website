# app/controllers/home_controller
# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to page_path("home"), turbo: false
  end
end
