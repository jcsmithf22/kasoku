require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "index" do
    get root_path

    assert_response :success
  end

  test "show an owned space" do
    get space_path(spaces(:one))

    assert_response :success
  end

  test "show a joined space" do
    space = spaces(:two)
    space.space_memberships.create!(user: @user, role: "member")

    get space_path(space)

    assert_response :success
  end

  test "show rejects a space the user cannot access" do
    get space_path(spaces(:two))

    assert_response :unprocessable_entity
  end

  test "create with valid params as HTML" do
    assert_difference "Space.count", 1 do
      post spaces_path, params: { space: { name: "New Space", description: "Notes" } }
    end

    space = Space.order(:id).last
    assert_redirected_to space
    assert_equal @user, space.owner
    assert_equal "Notes", space.description
  end

  test "create with valid params as Turbo Stream" do
    assert_difference "Space.count", 1 do
      post spaces_path,
        params: { space: { name: "New Space" } },
        as: :turbo_stream
    end

    assert_response :success
    assert_equal @user, Space.order(:id).last.owner
  end

  test "create with invalid params as HTML" do
    assert_no_difference "Space.count" do
      post spaces_path, params: { space: { name: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "create with invalid params as Turbo Stream" do
    assert_no_difference "Space.count" do
      post spaces_path, params: { space: { name: "" } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "owner destroys a space" do
    space = spaces(:one)

    assert_difference "Space.count", -1 do
      delete space_path(space)
    end

    assert_redirected_to root_path
  end

  test "joined user cannot destroy a space" do
    space = spaces(:two)
    space.space_memberships.create!(user: @user, role: "member")

    assert_no_difference "Space.count" do
      delete space_path(space)
    end

    assert_redirected_to space
  end
end
