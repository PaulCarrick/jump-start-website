# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  include Pagy::Backend

  #  before_action :authenticate_user! # Ensure only authenticated users can access
  before_action :set_user, only: [ :edit, :update, :destroy ]
  before_action :check_admin

  def initialize(...)
    super

    @title = "#{get_site_information.site_name} - Admin Dashboard: Users"

    set_title(@title)
  end

  def check_admin
    if @application_user
      redirect_to root_path, turbo: false, alert: "Access denied." unless @application_user.admin?
    else
      redirect_to root_path, turbo: false, alert: "Access denied." unless current_user.admin?
    end
  end

  def index
    @q = User.ransack(params[:q]) # Initialize Ransack search object

    # Set default sort column and direction
    sort_column    = params[:sort].presence || "email"
    sort_direction = params[:direction].presence || "asc"

    # Safeguard against invalid columns and directions
    sort_column    = User.column_names.include?(sort_column) ? sort_column : "email"
    sort_direction = %w[asc desc].include?(sort_direction) ? sort_direction : "asc"

    # Combine sorting and Ransack results
    sorted_results = @q.result(distinct: true).order("#{sort_column} #{sort_direction}")

    # Paginate the sorted results
    @pagy, @users = pagy(sorted_results, limit: 20)
  end

  def show
    set_user
  end

  def new
    @user = User.new
  end

  def create
    begin
      throw "You are not permitted to change #{class_title}." unless @application_user.admin?

      @user = User.new(user_params)

      @user.save!

      redirect_to admin_users_path, turbo: false, notice: "User created successfully."
    rescue => e
      handle_error(:new, e)
    end
  end

  def edit
    set_user
  end

  def update
    begin
      throw "You are not permitted to change #{class_title}." unless @application_user.admin?

      @user.update!(user_params)
      redirect_to admin_users_path, turbo: false, notice: "User updated successfully"
    rescue => e
      handle_error(:edit, e)
    end
  end

  def destroy
    begin
      throw "You are not permitted to change #{class_title}." unless @application_user.admin?

      set_user

      @user.destroy!

      redirect_to admin_users_path, turbo: false, notice: "User deleted successfully."
    rescue => e
      handle_error(:index, e)
    end
  end

  private

  def handle_error(action, e)
    debugger if ((Rails.env == 'development' || Rails.env == 'test')) && ENV["PAUSE_ERRORS"]

    @error_message = @user.errors&.full_messages&.join(", ")
    @error_message = e&.message unless @error_message.present?
    @error_message = "An error occurred." unless @error_message.present?
    @error_message = "There was an error with the User: #{@error_message}"
    flash[:error]  = @error_message

    redirect_to action: action, turbo: false
  end

  def set_user
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:id,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :name,
                                 :access,
                                 :roles)
  end
end
