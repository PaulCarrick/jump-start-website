# frozen_string_literal: true

class BlogsController < ApplicationController
  include HtmlSanitizer

  def index
    @blog_type = params[:blog_type].presence || "Personal"
    @contents = BlogPost.publicly_visible.where(blog_type: @blog_type).map do |blog|
      sanitize_html(blog.content)
    end
  end

  def show
    @blog_type = params[:blog_type].presence || "Personal"
    visible_posts = signed_in? ? BlogPost.all : BlogPost.publicly_visible

    if params[:id] == "latest"
      @blog = visible_posts.where(blog_type: @blog_type).order(posted: :desc).first
      @blog.content = sanitize_html(@blog.content) if @blog.present?
      render "latest"
    else
      @blog = visible_posts.find_by(id: params[:id])
      @blog.content = sanitize_html(@blog.content) if @blog.present?
      render "show", status: @blog.present? ? :ok : :not_found
    end
  end
end
