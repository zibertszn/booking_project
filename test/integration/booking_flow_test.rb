require "test_helper"

class BookingFlowTest < ActionDispatch::IntegrationTest
  test "guest can browse resources but must sign in to book" do
    get resources_path

    assert_response :success
    assert_select "h1", text: "Доступные ресурсы"
    assert_select "a[href='#{resource_path(resources(:meeting_room))}']"

    get resource_path(resources(:meeting_room))

    assert_response :success
    assert_select ".ui-alert", text: /войдите в аккаунт/

    post bookings_path, params: {
      booking: {
        resource_id: resources(:meeting_room).id,
        starts_at: "2030-01-15T13:00",
        ends_at: "2030-01-15T14:00"
      }
    }

    assert_redirected_to sign_in_path
  end

  test "authenticated user can publish a resource" do
    sign_in_as(users(:alice))

    get resources_path
    assert_select "a[href='#{new_resource_path}']"
    get new_resource_path
    assert_response :success
    assert_select "form[action='#{resources_path}']"

    assert_difference "Resource.count", 1 do
      post resources_path, params: {
        resource: {
          name: "Alice's Projector",
          description: "Portable projector",
           resource_type: "item"
        }
      }
    end

    resource = Resource.order(:id).last
    assert_equal users(:alice), resource.user
    assert_redirected_to resource_path(resource)
    follow_redirect!
    assert_select "h1", text: "Alice's Projector"
    assert_select "body", text: /Опубликовал: #{users(:alice).name}/
    get resources_path
    assert_select "a[href='#{resource_path(resource)}']"
  end

  test "authenticated user can view and delete their own announcements" do
    sign_in_as(users(:alice))
    resource = Resource.create!(name: "Alice's Room", resource_type: "property", user: users(:alice))

    get my_resources_path

    assert_response :success
    assert_select "h1", text: "Мои объявления"
    assert_select "h2", text: resource.name

    assert_difference "Resource.count", -1 do
      delete resource_path(resource)
    end

    assert_redirected_to my_resources_path
    follow_redirect!
    assert_select ".ui-alert--success", text: "Объявление удалено."
    assert_select "h2", text: resource.name, count: 0
  end

  test "guest cannot access their announcements" do
    get my_resources_path

    assert_redirected_to sign_in_path
  end

  test "user cannot delete another user's announcement" do
    resource = Resource.create!(name: "Alice's Equipment", resource_type: "item", user: users(:alice))
    sign_in_as(users(:bob))

    assert_no_difference "Resource.count" do
      delete resource_path(resource)
    end

    assert_redirected_to my_resources_path
    follow_redirect!
    assert_select ".ui-alert--danger", text: "Вы можете удалять только свои объявления."
  end

  test "guest cannot publish a resource" do
    get new_resource_path
    assert_redirected_to sign_in_path

    assert_no_difference "Resource.count" do
      post resources_path, params: { resource: { name: "Guest Resource", resource_type: "item" } }
    end

    assert_redirected_to sign_in_path
  end

  test "publishing returns validation errors" do
    sign_in_as(users(:alice))

    assert_no_difference "Resource.count" do
      post resources_path, params: { resource: { name: "", resource_type: "item" } }
    end

    assert_response :unprocessable_entity
    assert_select ".ui-alert--danger"
    assert_select "h1", text: "Добавить ресурс"
  end

  test "publisher cannot override author or publication status" do
    sign_in_as(users(:alice))

    post resources_path, params: {
      resource: { name: "My equipment", resource_type: "item", user_id: users(:bob).id, active: false }
    }

    resource = Resource.find_by!(name: "My equipment")
    assert_equal users(:alice), resource.user
    assert resource.active?
    assert_redirected_to resource_path(resource)
  end

  test "duplicate resource name preserves submitted fields" do
    sign_in_as(users(:alice))

    assert_no_difference "Resource.count" do
      post resources_path, params: {
         resource: { name: resources(:meeting_room).name, description: "My description", resource_type: "item" }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".ui-alert--danger"
    assert_select "textarea[name='resource[description]']", text: "My description"
    assert_select "select[name='resource[resource_type]']"
  end

  test "authenticated user can create and cancel a booking" do
    sign_in_as(users(:alice))

    get resource_path(resources(:meeting_room))
    assert_response :success

    assert_difference "Booking.count", 1 do
      post bookings_path, params: {
        booking: {
          resource_id: resources(:meeting_room).id,
          starts_at: "2030-01-15T13:00",
          ends_at: "2030-01-15T14:00"
        }
      }
    end

    booking = Booking.order(:id).last
    assert_equal users(:alice), booking.user
    assert_equal resources(:meeting_room), booking.resource
    assert_equal Time.zone.parse("2030-01-15T13:00"), booking.starts_at
    assert_equal Time.zone.parse("2030-01-15T14:00"), booking.ends_at
    assert_redirected_to my_bookings_path
    follow_redirect!
    assert_select "h1", text: "Мои бронирования"
    assert_select "h2", text: resources(:meeting_room).name
    assert_select ".ui-alert--success", text: "Бронирование успешно создано."

    assert_difference "Booking.count", -1 do
      delete booking_path(booking)
    end

    assert_redirected_to my_bookings_path
  end

  test "booking form rejects an occupied interval" do
    sign_in_as(users(:alice))

    assert_no_difference "Booking.count" do
      post bookings_path, params: {
        booking: {
          resource_id: resources(:meeting_room).id,
          starts_at: "2030-01-15T11:00",
          ends_at: "2030-01-15T13:00"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".ui-alert--danger", text: /Не удалось создать бронирование/
    assert_select "h1", text: resources(:meeting_room).name
  end

  test "availability endpoint reports occupied and free intervals" do
    get availability_resource_path(resources(:meeting_room)), params: {
      starts_at: "2030-01-15T11:00",
      ends_at: "2030-01-15T13:00"
    }

    assert_response :success
    assert_equal false, response.parsed_body["available"]

    get availability_resource_path(resources(:meeting_room)), params: {
      starts_at: "2030-01-15T12:00",
      ends_at: "2030-01-15T13:00"
    }

    assert_response :success
    assert_equal true, response.parsed_body["available"]
  end

  test "availability endpoint rejects an invalid interval" do
    get availability_resource_path(resources(:meeting_room)), params: {
      starts_at: "2030-01-15T14:00",
      ends_at: "2030-01-15T13:00"
    }

    assert_response :unprocessable_entity
    assert_equal false, response.parsed_body["available"]
    assert_equal "Укажите корректный интервал времени.", response.parsed_body["error"]
  end

  test "booking always belongs to the signed-in user" do
    sign_in_as(users(:bob))

    assert_difference "Booking.count", 1 do
      post bookings_path, params: {
        booking: {
          resource_id: resources(:training_room).id,
          starts_at: "2030-01-16T13:00",
          ends_at: "2030-01-16T14:00",
          user_id: users(:alice).id
        }
      }
    end

    booking = Booking.order(:id).last
    assert_equal users(:bob), booking.user
    assert_redirected_to my_bookings_path
  end

  test "user cannot cancel another user's booking" do
    sign_in_as(users(:bob))

    assert_no_difference "Booking.count" do
      delete booking_path(bookings(:existing_booking))
    end

    assert_redirected_to my_bookings_path
    follow_redirect!
    assert_select ".ui-alert--danger", text: /только свои бронирования/
  end

  private

  def sign_in_as(user)
    post sign_in_path, params: { session: { email: user.email, password: "password" } }
    assert_redirected_to root_path
  end
end
