module Checksum
  require "openssl"

  extend ActiveSupport::Concern

  included do
    before_save :populate_checksum
    before_update :populate_checksum
  end

  private

  def populate_checksum
    if self.kind_of?(ImageFile)
      value = self.description if self.description.present?

      if self.caption.present?
        if value.present?
          value += self.caption
        else
          value = self.caption
        end
      end

      if value.present?
        self.checksum = generate_checksum(value)
      end
    elsif self.kind_of?(Section)
      if description.present?
        self.checksum = generate_checksum(description)
      end
    else
      if content.present?
        self.checksum = generate_checksum(content)
      end
    end
  end

  # Generate a 2048-bit checksum
  def generate_checksum(data)
    # SHA-512 produces a 512-bit (64-byte) hash
    digest = OpenSSL::Digest::SHA512.new

    # Create a 2048-bit checksum by hashing iteratively
    checksum = ""
    4.times do
      checksum += digest.digest(data).unpack1("H*") # Convert to hex
      data = digest.digest(data) # Hash again for different output
    end

    checksum
  end
end
