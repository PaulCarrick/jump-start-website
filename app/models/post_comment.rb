class PostComment < ApplicationRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Checksum
  include Validation

  belongs_to :blog_post

  validates :title, :author, :posted, :content, presence: true
  validate :content_is_valid

  def self.ransackable_attributes(auth_object = nil)
    %w[content]
  end

  private

  def verify_checksum
    verify_checksum_for(content)
  end

  def content_is_valid
    return unless content.present?

    skip_check = content =~ /^\s*<title>/

    unless skip_check || validate_html(content, :content)
      errors.add(:base, "Invalid HTML in Content.")
    end
  end
end
