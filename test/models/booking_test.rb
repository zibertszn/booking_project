require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "valid with a user, resource and future time interval" do
    booking = Booking.new(
      user: users(:alice),
      resource: resources(:meeting_room),
      starts_at: Time.zone.parse("2030-01-15 13:00"),
      ends_at: Time.zone.parse("2030-01-15 14:00")
    )

    assert booking.valid?
  end

  test "rejects an interval that ends before it starts" do
    booking = Booking.new(
      user: users(:alice),
      resource: resources(:meeting_room),
      starts_at: Time.zone.parse("2030-01-15 15:00"),
      ends_at: Time.zone.parse("2030-01-15 14:00")
    )

    assert_not booking.valid?
    assert_includes booking.errors[:ends_at], "must be after the start time"
  end

  test "rejects an overlapping booking for the same resource" do
    booking = Booking.new(
      user: users(:alice),
      resource: resources(:meeting_room),
      starts_at: Time.zone.parse("2030-01-15 11:00"),
      ends_at: Time.zone.parse("2030-01-15 13:00")
    )

    assert_not booking.valid?
    assert_includes booking.errors[:base], "resource is already booked for this time"
  end

  test "allows adjacent bookings and bookings for another resource" do
    adjacent_booking = Booking.new(
      user: users(:alice),
      resource: resources(:meeting_room),
      starts_at: Time.zone.parse("2030-01-15 12:00"),
      ends_at: Time.zone.parse("2030-01-15 13:00")
    )
    other_resource_booking = Booking.new(
      user: users(:alice),
      resource: resources(:training_room),
      starts_at: Time.zone.parse("2030-01-15 11:00"),
      ends_at: Time.zone.parse("2030-01-15 13:00")
    )

    assert adjacent_booking.valid?
    assert other_resource_booking.valid?
  end
end