Rails.application.config.to_prepare do
  # Attachment ownership is a stable logical record ID, not a content version.
  reflection = ActiveStorage::Attachment.reflect_on_association(:record)
  reflection.options[:primary_key] = :id
  reflection.remove_instance_variable(:@association_primary_key) if reflection.instance_variable_defined?(:@association_primary_key)
end
