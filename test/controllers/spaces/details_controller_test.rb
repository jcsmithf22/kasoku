require "test_helper"

class Spaces::DetailsControllerTest < ActionDispatch::IntegrationTest
  test "owner can view details" do
    sign_in_as users(:one)

    get space_details_path(spaces(:one))

    assert_response :success
  end

  test "joined user can view details" do
    space = spaces(:one)
    space.space_memberships.create!(user: users(:two), role: "viewer")
    sign_in_as users(:two)

    get space_details_path(space)

    assert_response :success
  end

  test "unrelated user cannot view details" do
    sign_in_as users(:two)

    get space_details_path(spaces(:one))

    assert_response :unprocessable_entity
  end
end
