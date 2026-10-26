class User < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :destroy
  has_many :resources, dependent: :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, allow_nil: true
end
