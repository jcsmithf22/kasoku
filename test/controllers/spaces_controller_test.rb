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
    get space_url(spaces(:one).slug)
    assert_response :success
  end

  test "creates a space and owner membership via Turbo" do
    assert_difference("Space.count") do
      assert_difference("SpaceMembership.count") do
        post spaces_url,
             params: { space: { name: "New Space" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end
    end

    assert_response :success
    assert_equal @user, Space.order(:id).last.owner
  end
end
