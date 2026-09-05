require "test_helper"

class Spaces::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space = spaces(:one)
    sign_in_as users(:one)
  end

  test "gets members for an owner without a membership" do
    get space_members_url(@space)
    assert_response :success
    assert_select "li span", text: "owner", count: 1
    assert_select "button[title='Leave']", count: 0
  end

  test "gets the new member form for an owner" do
    get new_space_member_url(@space)
    assert_response :success
  end

  test "renders shared members alongside the owner" do
    @space.space_memberships.create!(user: users(:two), role: "member")

    get space_members_url(@space)

    assert_response :success
    assert_select "li span", text: users(:two).full_name
    assert_select "li span", text: "owner", count: 1
    assert_select "button[title='Remove']", count: 1
  end

  test "cannot assign owner as a membership role" do
    assert_no_difference "SpaceMembership.count" do
      post space_members_url(@space), params: {
        space_membership: { user: users(:two).email_address, role: "owner" }
      }
    end

    assert_response :unprocessable_entity
  end
end
