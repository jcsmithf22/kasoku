require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "shows the login form without authentication" do
    get new_session_url
    assert_response :success
  end

  test "creates a session for valid credentials" do
    assert_difference("Session.count") do
      post session_url,
           params: { user: { email: @user.email, password: "password" } }
    end

    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  test "rejects invalid credentials" do
    assert_no_difference("Session.count") do
      post session_url,
           params: { user: { email: @user.email, password: "password".reverse } }
    end

    assert_response :unprocessable_entity
  end

  test "destroys the current session" do
    sign_in_as @user

    assert_difference("Session.count", -1) do
      delete logout_url
    end

    assert_redirected_to new_session_url
    assert_empty cookies[:session_id]
  end
end
