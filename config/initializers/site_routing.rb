require Rails.root.join('lib/site_database_router')
require Rails.root.join('lib/site_cookie_store')

Rails.application.config.middleware.insert_after ActionDispatch::Executor, SiteDatabaseRouter
Rails.application.config.session_store SiteCookieStore, key: '_rails_website_session'

ActiveSupport.on_load(:active_storage_record) do
  # Blob/attachment writes must share the exact pool and transaction of their
  # owning content record, rather than a second connection to the same database.
  define_singleton_method(:connection_pool) { ApplicationRecord.connection_pool }
end

module SiteStorageVerifier
  def verifier
    return super unless SiteContext.tenant?
    Rails.application.message_verifier("ActiveStorage:site:#{SiteContext.key}")
  end
end
ActiveStorage.singleton_class.prepend(SiteStorageVerifier)

ActiveSupport.on_load(:active_storage_blob) do
  define_singleton_method(:signed_id_verifier) { ActiveStorage.verifier }
end

module SiteStorageUrls
  extend ActiveSupport::Concern
  included { before_action :site_storage_urls }

  def site_storage_urls
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port, script_name: request.script_name }
  end
end
Rails.application.config.to_prepare do
  ActiveStorage::BaseController.include(SiteStorageUrls)
end

ActiveSupport.on_load(:active_job) do
  prepend SiteJobContext
end

require Rails.root.join('lib/site_devise_mount')
Devise::FailureApp.prepend(SiteDeviseMount)
