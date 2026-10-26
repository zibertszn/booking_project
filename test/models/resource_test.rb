require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "valid with a name and resource type" do
    resource = Resource.new(name: "Conference Room", resource_type: "property")

    assert resource.valid?
  end

  test "normalizes name and rejects an invalid resource type" do
    resource = Resource.new(name: "  Conference Room  ", resource_type: "invalid")

    assert_not resource.valid?
    assert_equal "Conference Room", resource.name
    assert_includes resource.errors[:resource_type], "is not included in the list"
  end

  test "requires a unique name" do
    resource = Resource.new(name: resources(:meeting_room).name, resource_type: "item")

    assert_not resource.valid?
    assert_includes resource.errors[:name], "has already been taken"
  end
end