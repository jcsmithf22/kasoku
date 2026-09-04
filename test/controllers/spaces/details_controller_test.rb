require "test_helper"

class Spaces::DetailsControllerTest < ActionDispatch::IntegrationTest
  test "gets details for a member" do
    sign_in_as users(:one)

    get space_details_url(spaces(:one).slug)

    assert_response :success
  end
end
