class BlogPost < ApplicationRecord
  after_find :verify_checksum, unless: -> { Thread.current[:skip_checksum_verification] }

  include Checksum
  include Validation

  has_many :post_comments, dependent: :destroy

  validates :title, :author, :posted, :content, presence: true
  validate :content_is_valid

  ransacker :posted_date, formatter: proc { |v| v.to_date.iso8601 } do |parent|
    Arel::Nodes::NamedFunction.new('DATE', [ parent.table[:posted] ])
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[ author title posted posted_date content ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ post_comments ]
  end

  private

  def verify_checksum
    return unless content.present?

    expected_checksum = generate_checksum(content)

    unless checksum == expected_checksum
      Rails.logger.error "Checksum mismatch for record ##{id}"
      raise ActiveRecord::RecordInvalid, "Checksum verification failed for BlogPost record ##{id}"
    end
  end

  def content_is_valid
    return unless content.present?

    skip_check = content =~ /^\s*<title>/

    unless skip_check || validate_html(content, :content)
      errors.add(:base, "Invalid HTML in Content.")
    end
  end
end
