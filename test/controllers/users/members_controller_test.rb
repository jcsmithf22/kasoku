require "test_helper"

class Users::MembersControllerTest < ActionDispatch::IntegrationTest
  test "joined user leaves a space" do
    user = users(:one)
    space = spaces(:two)
    space.space_memberships.create!(user: user, role: "member")
    sign_in_as user

    assert_difference "SpaceMembership.count", -1 do
      delete users_member_path(space.id)
    end

    assert_redirected_to root_path
    assert_not user.accessible_spaces.exists?(space.id)
  end

  test "owner cannot leave their own space" do
    sign_in_as users(:one)

    assert_no_difference "SpaceMembership.count" do
      delete users_member_path(spaces(:one).id)
    end

    assert_response :unprocessable_entity
  end
end
