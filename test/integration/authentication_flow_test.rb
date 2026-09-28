require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "user can sign up" do
    assert_difference "User.count", 1 do
      post sign_up_path, params: {
        user: {
          name: "New User",
          email: "new@example.com",
          password: "secret1",
          password_confirmation: "secret1"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select ".app-nav__user", text: "New User"
  end

  test "user can sign in and sign out" do
    post sign_in_path, params: { session: { email: users(:alice).email, password: "password" } }

    assert_redirected_to root_path
    follow_redirect!
    assert_select ".app-nav__user", text: users(:alice).name

    delete sign_out_path

    assert_redirected_to sign_in_path
    follow_redirect!
    assert_select "a", text: "Создать аккаунт"
  end

  test "invalid sign in rerenders form" do
    post sign_in_path, params: { session: { email: users(:alice).email, password: "wrong" } }

    assert_response :unprocessable_entity
    assert_select ".ui-alert--danger", text: /Неверный email или пароль/
  end
end