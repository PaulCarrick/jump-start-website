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
      @contact = Contact.new(contact_params)
      unless Recaptcha.configuration.site_key.present? && Recaptcha.configuration.secret_key.present? &&
             verify_recaptcha(model: @contact, action: "contact", minimum_score: 0.5)
        @error_message = "reCAPTCHA verification failed. Please try again."
        render :new, status: :unprocessable_content
        return
      end
      @contact.save!

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

      if @contact&.persisted?
        @contact.submit_information = @error_message
        @contact.save
      end

      redirect_to action: :new, turbo: false, notice: "There are errors in the form. Please try again."
    rescue => e
      debugger if Rails.env == 'development' && ENV["PAUSE_ERRORS"]

      # Show visitors what to fix in the form, but never the server's own error
      # text (it can name the mail server and its settings). That goes to the log.
      Rails.logger.error("Contact form could not be sent: #{e.class}: #{e.message}")
      @error_message = @contact&.errors&.full_messages&.join(", ")
      @error_message = "Your message could not be sent. Please try again later." unless @error_message.present?
      flash[:error]  = @error_message

      if @contact&.persisted?
        @contact.submit_information = @error_message
        @contact.save
      end

      redirect_to action: :new, turbo: false, notice: "There are errors in the form. Please try again."
    end
  end

  def show
    @contact = Contact.enabled.find(params[:id])
    @results = @contact.submit_information
  end

  private

  def contact_params
    params.require(:contact).permit(:id, :name, :email, :phone, :message)
  end
end
