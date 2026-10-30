# A draft points at an immutable blob without replacing the live attachment.
class DraftImageAttachment < SimpleDelegator
  def initialize(owner)
    @owner = owner
    super(owner.attachment_blob_id && ActiveStorage::Blob.find_by(id: owner.attachment_blob_id))
  end

  def attached? = __getobj__.present?
  def blob = __getobj__
  def attach(value) = @owner.image = value
  def purge = @owner.attachment_blob_id = nil
  def present? = attached?
  def blank? = !attached?
end
