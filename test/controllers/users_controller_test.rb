require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "gets the current user's profile" do
    sign_in_as users(:one)

    get profile_url

    assert_response :success
  end

  test "redirects an unauthenticated profile request to login" do
    get profile_url

    assert_redirected_to new_session_url
  end
end
