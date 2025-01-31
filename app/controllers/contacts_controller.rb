# app/controllers/contacts_controller.rb

# frozen_string_literal: true

class ContactsController < ApplicationController
  def initialize(...)
    super

    @title = "#{get_site_information.site_name} - Contact"

    set_title(@title)
  end

  def new
    @contact = Contact.new
  end

  def create
    begin
      @contact = Contact.create!(contact_params)

      # raise "Invalid Captcha." unless verify_recaptcha(model: @contact)

      ContactMailer.contact_email(@contact.name,
                                  @contact.email,
                                  @contact.phone,
                                  @contact.message,
                                  @site_information).deliver_now

      @contact.submit_information = "The contact information was successfully sent."
      @contact.save!

      flash[:info] = @contact.submit_information

      redirect_to contact_path(@contact), turbo: false
    rescue ActiveRecord::RecordNotUnique => e
      @error_message = "You cannot submit the form twice with the exact same information. Please at least change the message."
      flash[:error]  = @error_message

      if @contact.present?
        @contact.submit_information = @error_message
        @contact.save
      end

      redirect_to action: :new, turbo: false, notice: "There are error in the form. Please try again."
    rescue => e
      debugger if Rails.env == 'development' && ENV["PAUSE_ERRORS"]

      @error_message = @contact&.errors&.full_messages&.join(", ")
      @error_message = e&.message unless @error_message.present?
      flash[:error]  = @error_message

      if @contact.present?
        @contact.submit_information = @error_message
        @contact.save
      end

      redirect_to action: :new, turbo: false, notice: "There are error in the form. Please try again."
    end
  end

  def show
    @contact = Contact.find(params[:id])
    @results = @contact.submit_information
  end

  private

  def contact_params
    params.require(:contact).permit(:id, :name, :email, :phone, :message)
  end
end
