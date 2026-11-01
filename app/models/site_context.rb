class SiteContext < ActiveSupport::CurrentAttributes
  attribute :database, :setup_id, :mount_path, :key

  def self.tenant?
    key.present?
  end

  def self.catalog?
    !tenant?
  end
end
