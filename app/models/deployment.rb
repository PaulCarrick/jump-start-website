class Deployment < ApplicationRecord
  validates :effective_at, presence: true
end
