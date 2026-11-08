class User < ApplicationRecord
  include Enableable
  include BitemporalRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Devise's unscoped uniqueness check also sees retired temporal versions.
  # Replace only that check, retaining its other email/password validations.
  _validators[:email].select { |validator| validator.is_a?(ActiveRecord::Validations::UniquenessValidator) }.each do |validator|
    skip_callback(:validate, :before, validator)
    _validators[:email].delete(validator)
  end
  validates_uniqueness_of :email, allow_blank: true, case_sensitive: true,
                         if: :devise_will_save_change_to_email?,
                         conditions: -> { working_or_live }

  # The access levels the Users form offers, plus the guest account's. Accounts
  # made through sign-up have none.
  ACCESS_LEVELS = %w[regular read_only blogs admin super guest].freeze

  validates :password, presence: true, on: :create
  # (Devise already checks that the password confirmation matches.)
  validates :access, inclusion: { in: ACCESS_LEVELS }, allow_blank: true

  # Skip password validation if the password is blank during update
  def password_required?
    new_record? || password.present?
  end

  def self.rememberable_options
    options = super
    SiteContext.tenant? ? options.merge(key: "remember_user_#{SiteContext.key}_token") : options
  end

  def regular?
    !access.present? || (access === 'regular')
  end

  def read_only?
    access === 'read_only'
  end

  def blogs?
    (access === 'blogs') || admin?
  end

  def admin?
    (access === 'admin') || (access === 'super')
  end

  def super?
    access === 'super'
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email name]
  end
end
