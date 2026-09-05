require "test_helper"

class Spaces::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @space = spaces(:one)
    @owner = users(:one)
    @other_user = users(:two)
    sign_in_as @owner
  end

  test "index" do
    get space_members_path(@space)

    assert_response :success
  end

  test "new" do
    get new_space_member_path(@space)

    assert_response :success
  end

  test "owner adds a member and returns to the space" do
    assert_difference "SpaceMembership.count", 1 do
      post space_members_path(@space), params: {
        space_membership: { user: @other_user.email_address, role: "member" }
      }
    end

    assert_redirected_to @space
    assert @space.space_memberships.exists?(user: @other_user, role: "member")
  end

  test "owner adds a viewer and returns to members" do
    post space_members_path(@space), params: {
      space_membership: { user: @other_user.email_address, role: "viewer", from: "members" }
    }

    assert_redirected_to space_members_path(@space)
    assert @space.space_memberships.exists?(user: @other_user, role: "viewer")
  end

  test "invalid member renders new" do
    assert_no_difference "SpaceMembership.count" do
      post space_members_path(@space), params: {
        space_membership: { user: "missing@example.com", role: "member" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "joined user cannot open or submit the add member form" do
    @space.space_memberships.create!(user: @other_user, role: "member")
    sign_in_as @other_user

    get new_space_member_path(@space)
    assert_redirected_to @space

    assert_no_difference "SpaceMembership.count" do
      post space_members_path(@space), params: {
        space_membership: { user: "missing@example.com", role: "viewer" }
      }
    end
    assert_redirected_to @space
  end

  test "owner removes a member" do
    membership = @space.space_memberships.create!(user: @other_user, role: "member")

    assert_difference "SpaceMembership.count", -1 do
      delete space_member_path(@space, membership)
    end

    assert_redirected_to space_members_path(@space)
  end

  test "member removes their own membership" do
    membership = @space.space_memberships.create!(user: @other_user, role: "member")
    sign_in_as @other_user

    assert_difference "SpaceMembership.count", -1 do
      delete space_member_path(@space, membership)
    end

    assert_redirected_to space_members_path(@space)
  end

  test "viewer cannot remove another member" do
    viewer = @space.space_memberships.create!(user: @other_user, role: "viewer")
    member = @space.space_memberships.create!(user: User.create!(
      email_address: "member@example.com",
      password: "password",
      first_name: "Other",
      last_name: "Member"
    ), role: "member")
    sign_in_as @other_user

    assert_no_difference "SpaceMembership.count" do
      delete space_member_path(@space, member)
    end

    assert_redirected_to @space
    assert SpaceMembership.exists?(viewer.id)
    assert SpaceMembership.exists?(member.id)
  end
end
