require "test_helper"

class Spaces::MembersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spaces_members_index_url
    assert_response :success
  end

  test "should get new" do
    get spaces_members_new_url
    assert_response :success
  end
end
