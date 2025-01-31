# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp image_files, web push, badges, import maps, CSS nesting, and CSS :has.
  #  allow_browser versions: :modern

  before_action :setup_site
  before_action :setup_main_menu_items
  before_action :setup_admin_menu_items
  before_action :setup_footer_items

  def get_site_information
    setup_site unless @site_information.present?

    @site_information
  end

  def set_title(title)
    @title = title
  end

  def get_title
    @title
  end

  def set_current_user(user)
    @application_user = user if Rails.env == 'test' # Only for testing.
  end

  def get_current_user
    @application_user
  end

  def current_user_is_admin?
    signed_in? && @application_user.present? && @application_user.admin?
  end

  if Rails.env === "test"
    def signin_user(user)
      @signed_in    = false
      @current_user = user

      signed_in?
    end
  end

  private

  def setup_site
    @site_information = SiteSetup.find_by(default_setup: true)

    unless @site_information.present?
      @site_information = SiteSetup.first

      unless @site_information.present?
        @site_information = SiteSetup.new(configuration_name:    'default',
                                          site_name:             'Jump Start Server',
                                          site_domain:           'jumpstartserver.com',
                                          site_host:             'jumpstartserver.com',
                                          site_url:              'https://jumpstartserver.com',
                                          header_background:     '#0d6efd',
                                          header_text_color:     '#f8f9fa',
                                          footer_background:     '#0d6efd',
                                          footer_text_color:     '#f8f9fa',
                                          container_background:  '#f8f9fa',
                                          container_text_color:  '#000000',
                                          page_background_image: "none",
                                          facebook_url:          nil,
                                          twitter_url:           nil,
                                          instagram_url:         nil,
                                          linkedin_url:          nil,
                                          github_url:            nil,
                                          owner_name:            'Anyone',
                                          copyright:             'Copyright © 2025',
                                          guest_user_name:       'guest')
      end
    end

    @title            = @site_information.site_name unless @title.present?
  end

  # TO DO Remove this when we can figure out what's wrong with the devise setup
  # This only seems to affect the test environment
  def signed_in?
    return @signed_in if @signed_in

    @signed_in = false

    if Rails.env != "test"
      @signed_in = user_signed_in?

      if @signed_in
        @application_user ||= User.find(current_user.id)
      end
    else
      begin
        @signed_in        = user_signed_in?
        @application_user = current_user
      rescue ArgumentError => e
        if e.message == "wrong number of arguments (given 1, expected 2)"
          warden_user       = session["warden.user.user.key"]
          @signed_in        = warden_user[:approved] if warden_user.present?
          @application_user ||= User.find(warden_user[:id])
        else
          raise e
        end
      end
    end

    if @site_information.special_user_name.present? && request.url.include?(@site_information.special_user_name)
      @application_user ||= User.find_by(name: @site_information.special_user_name)
      @signed_in        = true
    else
      @application_user ||= User.find_by(name: @site_information.guest_user_name)
    end

    @signed_in
  end

  def setup_main_menu_items
    return @main_menu_items if @main_menu_items.present? && !@signed_in

    main_menu_items ||= MenuItem.where(menu_type: "Main", parent_id: nil)
                                .order(:menu_order)
                                .includes(:sub_items)
                                .references(:sub_items)
                                .order("menu_items.menu_order", "sub_items_menu_items.menu_order")

    if !signed_in? || !@application_user.present?
      @main_menu_items = main_menu_items
    else
      @main_menu_items = []

      main_menu_items.each do |main_menu_item|
        if main_menu_item.access.present?
          if main_menu_item.access =~ /^!(.+)$/
            if Regexp.last_match(1) != @application_user.roles
              @main_menu_items << main_menu_item
            end
          else
            if Regexp.last_match(1) == @application_user.roles
              @main_menu_items << main_menu_item
            end
          end
        else
          if main_menu_item.link&.strip == "/users/sign_in"
            main_menu_item.label = "logout"
            main_menu_item.icon  = "/images/no-keys.svg"
            main_menu_item.link  = "/users/sign_out"
            @main_menu_items << main_menu_item
          else
            @main_menu_items << main_menu_item
          end
        end
      end
    end
  end

  def setup_admin_menu_items
    return @admin_menu_items if @admin_menu_items.present?

    @admin_menu_items = MenuItem.where(menu_type: "Admin", parent_id: nil)
                                .order(:menu_order)
                                .includes(:sub_items)
                                .references(:sub_items)
                                .order("menu_items.menu_order", "sub_items_menu_items.menu_order")
  end

  def setup_footer_items
    return @footer_items if @footer_items.present? && !@signed_in

    footer_items ||= FooterItem.where(parent_id: nil)
                               .order(:footer_order)
                               .includes(:sub_items)
                               .references(:sub_items)
                               .order("footer_items.footer_order", "sub_items_footer_items.footer_order")

    if !signed_in? || !@application_user.present?
      @footer_items = footer_items
    else
      @footer_items = []

      footer_items.each do |footer_item|
        if footer_item.access.present?
          if footer_item.access =~ /^!(.+)$/
            if Regexp.last_match(1) != @application_user.roles
              @footer_items << footer_item
            end
          else
            if Regexp.last_match(1) == @application_user.roles
              @footer_items << footer_item
            end
          end
        else
          if footer_item.link&.strip == "/users/sign_in"
            footer_item.label = "logout"
            footer_item.icon  = "/images/no-keys.svg"
            footer_item.link  = "/users/sign_out"
            @footer_items << footer_item
          else
            @footer_items << footer_item
          end
        end
      end
    end

    @footer_items.each do |footer_item|
      footer_item.sub_items.each do |sub_item|
        next unless sub_item.link&.strip == "/users/sign_in"

        sub_item.label = "logout"
        sub_item.icon  = "/images/no-keys.svg"
        sub_item.link  = "/users/sign_out"

        break
      end

      next unless footer_item.link&.strip == "/users/sign_in"

      footer_item.label = "logout"
      footer_item.icon  = "/images/no-keys.svg"
      footer_item.link  = "/users/sign_out"

      break
    end
  end
end
