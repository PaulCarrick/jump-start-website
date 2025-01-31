class ContactMailer < ApplicationMailer
  def contact_email(name, email, phone, message, site_information)
    @sender_email   = email
    @sender_name    = name
    @sender_phone   = phone
    @sender_message = message

    mail(
      from:    site_information.contact_email_from,
      to:      site_information.contact_email_to,
      subject: site_information.contact_email_subject
    ) do |format|
      format.html
    end

    mail.delivery_method.settings.merge!(
      address:              site_information.smtp_server,
      port:                 site_information.smtp_port,
      domain:               site_information.smtp_domain,
      user_name:            site_information.smtp_user,
      password:             site_information.smtp_password,
      authentication:       site_information.smtp_authentication,
      enable_starttls_auto: true,
      enable_ssl:           false
    )
  end
end
