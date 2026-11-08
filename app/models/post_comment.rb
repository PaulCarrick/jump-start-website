class PostComment < ApplicationRecord
  include Enableable
  include BitemporalRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Checksum
  include Validation

  belongs_to :blog_post, primary_key: :id, foreign_key: :blog_post_id, inverse_of: :post_comments

  before_validation :clean_content

  validates :title, :author, :posted, :content, presence: true
  validate :content_is_valid

  def self.ransackable_attributes(auth_object = nil)
    %w[content]
  end

  # Administrators may change any comment; other users only the ones they wrote.
  def changeable_by?(user)
    return false unless user.present?

    user.admin? || (user_id.present? && user_id == user.id)
  end

  private

  def clean_content
    # Comments come from site visitors and are shown as HTML.
    self.content = HtmlCleaner.clean(content) if content.present?
  end

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
