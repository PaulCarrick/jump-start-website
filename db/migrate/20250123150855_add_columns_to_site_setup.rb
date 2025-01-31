class AddColumnsToSiteSetup < ActiveRecord::Migration[8.0]
  def change
    add_column :site_setups, :default_setup, :boolean, default: false
    add_column :site_setups, :guest_user_name, :string, default: 'guest'
    add_column :site_setups, :special_user_name, :string
    add_column :site_setups, :smtp_server, :string
    add_column :site_setups, :smtp_port, :string
    add_column :site_setups, :smtp_user, :string
    add_column :site_setups, :smtp_password, :string
    add_column :site_setups, :smtp_domain, :string
    add_column :site_setups, :smtp_authentication, :string
    add_column :site_setups, :contact_email_from, :string
    add_column :site_setups, :contact_email_to, :string
    add_column :site_setups, :contact_email_subject, :string
    add_column :site_setups, :captcha_site_key, :string
    add_column :site_setups, :captcha_secret_key, :string
  end
end
