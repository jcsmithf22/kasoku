require "test_helper"

class Spaces::DetailsControllerTest < ActionDispatch::IntegrationTest
  test "gets details for an owner without a membership" do
    sign_in_as users(:one)

    get space_details_url(spaces(:one))

    assert_response :success
    assert_select "section", text: /Members/ do
      assert_select "p", text: "Total: 0"
    end
  end

  test "counts only shared members" do
    sign_in_as users(:one)
    spaces(:one).space_memberships.create!(user: users(:two), role: "member")

    get space_details_url(spaces(:one))

    assert_response :success
    assert_select "section", text: /Members/ do
      assert_select "p", text: "Total: 1"
      assert_select "p", text: "Member: 1"
    end
  end
end
