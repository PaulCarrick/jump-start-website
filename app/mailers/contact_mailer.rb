class ContactMailer < ApplicationMailer
  def contact_email(name, email, phone, message, site_information)
    @sender_email   = email
    @sender_name    = name
    @sender_phone   = phone
    @sender_message = HtmlCleaner.clean(message)
    @owner_name     = site_information.owner_name.presence

    mail(
      from:     site_information.contact_email_from,
      to:       site_information.contact_email_to,
      reply_to: email.presence,
      subject:  site_information.contact_email_subject
    ) do |format|
      format.html
    end

    use_mail_server(site_information)
  end

  # A short message that shows whether the saved mail settings work.
  def test_email(site_information, recipient)
    mail(
      from:    site_information.contact_email_from,
      to:      recipient,
      subject: "Test email from #{site_information.site_name}"
    ) do |format|
      format.text do
        render plain: "This is a test email from the #{site_information.site_name} admin.\n\n" \
                      "If you can read it, the mail server settings work and contact form messages will reach this address.\n"
      end
    end

    use_mail_server(site_information)
  end

  private

  def use_mail_server(site_information)
    mail.delivery_method.settings.merge!(
      address:              site_information.smtp_server,
      port:                 site_information.smtp_port,
      domain:               site_information.smtp_domain,
      user_name:            site_information.smtp_user,
      password:             site_information.smtp_password,
      authentication:       site_information.smtp_authentication,
      enable_starttls_auto: true,
      ssl:                  false,
      tls:                  false
    )
  end
end
