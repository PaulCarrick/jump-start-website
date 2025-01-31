# app/controllers/blogs_controller.rb
# frozen_string_literal: true

include HtmlSanitizer

class BlogsController < ApplicationController
  def index
    @blog_type = params[:blog_type].present? ? params[:blog_type] : "Personal"
    @contents = BlogPost.where(blog_type:  @blog_type, visibility: 'Public').map do |blog|
      blog.content = sanitize_html(blog.content)
    end
  end

  def show
    @blog_type = params[:blog_type].present? ? params[:blog_type] : "Personal"

    if params[:id] == "latest"
      @blog = BlogPost.where(blog_type: @blog_type).order(posted: 'desc').first
      @blog.content = sanitize_html(@blog.content) if @blog.present?

      render "latest"

      nil
    else
      @blog = BlogPost.find(params[:id])
    end
  end
end
