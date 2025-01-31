# frozen_string_literal: true

class SearchController < ApplicationController
  def initialize(...)
    super

    @title = "#{get_site_information.site_name} - Search"

    set_title(@title)
  end

  def new
    @q = Section.ransack(params[:q]) # Initialize the Ransack object
  end
end
