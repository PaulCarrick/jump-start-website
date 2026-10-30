class PublishingContext < ActiveSupport::CurrentAttributes
  attribute :live, default: true
  attribute :editing, :deploying, :preview, :valid_at, :known_at, :expected_versions
end
