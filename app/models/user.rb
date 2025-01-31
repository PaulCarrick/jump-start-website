class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :password, presence: true, on: :create
  validates :password, confirmation: true, allow_blank: true

  # Skip password validation if the password is blank during update
  def password_required?
    new_record? || password.present?
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
