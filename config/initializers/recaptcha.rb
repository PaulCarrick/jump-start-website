# Local development keys stay outside Git and do not override exported settings.
if Rails.env.development?
  require "dotenv"
  Dotenv.load(Rails.root.join(".env.local"))
end

Recaptcha.configure do |config|
  config.site_key  = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
end
