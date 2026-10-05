class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :resource

  validate :ends_after_starts
  validate :resource_is_available

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") unless ends_at > starts_at
  end

  def resource_is_available
    return if resource_id.blank? || starts_at.blank? || ends_at.blank?
    return if errors.include?(:ends_at)

    overlapping_booking = Booking
      .where(resource_id: resource_id)
      .where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
      .exists?

    errors.add(:base, "resource is already booked for this time") if overlapping_booking
  end
end