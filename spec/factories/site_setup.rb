FactoryBot.define do
  factory :site_setup do
    configuration_name { 'default' }
    default_setup { true }
    site_name { 'Jump Start Server' }
    site_domain { 'jumpstartserver.com' }
    site_host { 'jumpstartserver.com' }
    site_url { 'https://jumpstartserver.com' }
    guest_user_name { 'guest' }
    special_user_name { nil }
    smtp_server { 'email-smtp.us-west-2.amazonaws.com' }
    smtp_port { 465 }
    smtp_user { 'AKIA4T4OCMYU4RARO7O5' }
    smtp_password { '' }
    smtp_domain { 'jumpstartserver.com' }
    smtp_authentication { 'login' }
    contact_email_from { 'jumpstart@jumpstartserver.com' }
    contact_email_to { 'jumpstart@jumpstartserver.com' }
    contact_email_subject { 'Contact Request From Jumpstart.com' }
    captcha_site_key { '6LfMwnEqAAAAAP2KC-014xjgglMTBwiMWn2BM3Lw' }
    captcha_secret_key { '' }
    header_background { '#0d6efd' }
    header_text_color { 'white' }
    footer_background { '#0d6efd' }
    footer_text_color { 'white' }
    container_background { 'white' }
    container_text_color { 'black' }
    page_background_image { "none" }
    facebook_url { 'https://www.facebook.com/test' }
    twitter_url { 'https://x.com/test' }
    instagram_url { 'https://www.instagram.com/test/' }
    linkedin_url { 'https://www.linkedin.com/in/test/' }
    github_url { 'https://github.com/test' }
    owner_name { 'Test User' }
    copyright { 'Copyright © 2024 test.com all rights reserved' }
  end
end
