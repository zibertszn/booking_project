require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid with name email and password" do
    user = User.new(name: "John", email: "john@example.com", password: "secret1", password_confirmation: "secret1")

    assert user.valid?
  end

  test "normalizes email and name" do
    user = User.create!(name: "  John  ", email: "  JOHN@EXAMPLE.COM  ", password: "secret1", password_confirmation: "secret1")

    assert_equal "John", user.name
    assert_equal "john@example.com", user.email
  end

  test "requires unique email" do
    user = User.new(name: "Copy", email: users(:alice).email.upcase, password: "secret1", password_confirmation: "secret1")

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires password with minimum length" do
    user = User.new(name: "John", email: "john@example.com", password: "123", password_confirmation: "123")

    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 6 characters)"
  end

  test "has many bookings" do
    assert_includes users(:alice).bookings, bookings(:existing_booking)
  end
end