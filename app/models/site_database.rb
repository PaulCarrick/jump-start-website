class SiteDatabase < CatalogRecord
  validates :name, :ownership_token, :site_setup_id, presence: true
end
