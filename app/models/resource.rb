class Resource < ApplicationRecord
  # Resources created before user publishing was introduced may have no author.
  belongs_to :user, optional: true
  has_many :bookings, dependent: :restrict_with_error
  has_one_attached :image

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: true
  validates :resource_type, presence: true, inclusion: { in: %w[property item] }
  validates :active, inclusion: { in: [ true, false ] }

  def resource_type_label
    { "property" => "Недвижимость", "item" => "Предмет" }.fetch(resource_type)
  end
end
