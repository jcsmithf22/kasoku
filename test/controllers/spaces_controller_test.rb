require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "gets index when authenticated" do
    get root_url
    assert_response :success
  end

  test "gets a space when authenticated" do
    get space_url(spaces(:one))
    assert_response :success
  end

  test "joined users can access a space but unrelated users cannot" do
    space = spaces(:two)
    get space_url(space)
    assert_response :unprocessable_entity

    space.space_memberships.create!(user: @user, role: "member")
    get space_url(space)
    assert_response :success
  end

  test "owner cannot leave but a joined user can" do
    space = spaces(:one)
    delete users_member_url(space.id)
    assert_response :unprocessable_entity
    assert_includes @user.accessible_spaces, space

    joined = spaces(:two)
    joined.space_memberships.create!(user: @user, role: "member")
    assert_difference "SpaceMembership.count", -1 do
      delete users_member_url(joined.id)
    end
    assert_redirected_to root_url
    assert_not_includes @user.accessible_spaces, joined
  end

  test "creates a space without an owner membership via Turbo" do
    assert_difference("Space.count") do
      assert_no_difference("SpaceMembership.count") do
        post spaces_url,
             params: { space: { name: "New Space" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end
    end

    assert_response :success
    assert_equal @user, Space.order(:id).last.owner
  end
end
