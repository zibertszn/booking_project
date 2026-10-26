class Resource < ApplicationRecord
  # Resources created before user publishing was introduced may have no author.
  belongs_to :user, optional: true
  has_many :bookings, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :active, inclusion: { in: [ true, false ] }
end
