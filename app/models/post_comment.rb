class PostComment < ApplicationRecord
  include Enableable
  include BitemporalRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Checksum
  include Validation

  # Comments come from site visitors and are shown as HTML, so keep only the
  # formatting the comment editor (Quill) produces. Scripts, event handlers,
  # images, frames, styles and javascript: links are removed.
  ALLOWED_TAGS = %w[p br strong b em i u s a ul ol li blockquote pre code h1 h2 h3 span sub sup].freeze
  ALLOWED_ATTRIBUTES = %w[href class].freeze

  belongs_to :blog_post, primary_key: :id, foreign_key: :blog_post_id, inverse_of: :post_comments

  before_validation :clean_content

  validates :title, :author, :posted, :content, presence: true
  validate :content_is_valid

  def self.ransackable_attributes(auth_object = nil)
    %w[content]
  end

  def self.clean_html(html)
    Rails::HTML5::SafeListSanitizer.new.sanitize(html.to_s, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end

  # Administrators may change any comment; other users only the ones they wrote.
  def changeable_by?(user)
    return false unless user.present?

    user.admin? || (user_id.present? && user_id == user.id)
  end

  private

  def clean_content
    self.content = self.class.clean_html(content) if content.present?
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
