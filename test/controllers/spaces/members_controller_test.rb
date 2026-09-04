require "test_helper"

class Spaces::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space = spaces(:one)
    sign_in_as users(:one)
  end

  test "gets members for a member" do
    get space_members_url(@space.slug)
    assert_response :success
  end

  test "gets the new member form for an owner" do
    get new_space_member_url(@space.slug)
    assert_response :success
  end
end
