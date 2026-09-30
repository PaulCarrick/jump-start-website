require "openssl"

module Checksum
  extend ActiveSupport::Concern

  included do
    before_save :populate_checksum
  end

  private

  def populate_checksum
    data = case self
    when ImageFile then [ description, caption ].compact.join
    when Section then description
    else content
    end
    self.checksum = generate_checksum(data) if data.present?
  end

  def verify_checksum_for(data, field = :base)
    return if data.blank? || checksum == generate_checksum(data)

    message = "Checksum verification failed for #{self.class.name} record ##{id}"
    errors.add(field, message)
    Rails.logger.error(message)
    raise ActiveRecord::RecordInvalid.new(self)
  end

  # Preserve the existing four-round SHA-512 format used by stored records.
  def generate_checksum(data)
    digest = OpenSSL::Digest::SHA512.new
    Array.new(4) do
      data = digest.digest(data)
      data.unpack1("H*")
    end.join
  end
end
