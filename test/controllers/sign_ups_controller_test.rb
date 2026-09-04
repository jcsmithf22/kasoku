require "test_helper"

class SignUpsControllerTest < ActionDispatch::IntegrationTest
  test "shows the sign up form without authentication" do
    get sign_up_url
    assert_response :success
  end

  test "redirects authenticated users" do
    sign_in_as users(:one)

    get sign_up_url

    assert_redirected_to root_url
  end

  test "creates a user and starts a session" do
    assert_difference("User.count") do
      assert_difference("Session.count") do
        post sign_up_url,
             params: {
               user: {
                 name: "New User",
                 email: "new@example.com",
                 password: "password",
                 password_confirmation: "password"
               }
             }
      end
    end

    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  test "rejects invalid sign up details" do
    assert_no_difference(["User.count", "Session.count"]) do
      post sign_up_url,
           params: {
             user: {
               name: "New User",
               email: "new@example.com",
               password: "password",
               password_confirmation: "password".upcase
             }
           }
    end

    assert_response :unprocessable_entity
  end
end
