require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "valid with a name and positive capacity" do
    resource = Resource.new(name: "Conference Room", capacity: 12)

    assert resource.valid?
  end

  test "normalizes name and rejects non-positive capacity" do
    resource = Resource.new(name: "  Conference Room  ", capacity: 0)

    assert_not resource.valid?
    assert_equal "Conference Room", resource.name
    assert_includes resource.errors[:capacity], "must be greater than 0"
  end

  test "requires a unique name" do
    resource = Resource.new(name: resources(:meeting_room).name, capacity: 4)

    assert_not resource.valid?
    assert_includes resource.errors[:name], "has already been taken"
  end
end