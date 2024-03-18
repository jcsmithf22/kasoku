require "test_helper"

class Spaces::DetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spaces_details_index_url
    assert_response :success
  end
end
