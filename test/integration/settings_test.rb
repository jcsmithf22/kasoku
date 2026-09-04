require "test_helper"

class SettingsTest < ActionDispatch::IntegrationTest
  test "user settings nav" do
    sign_in_as users(:one)
    get settings_profile_path

    assert_dom "h4", "Account Settings"
    assert_dom "a", "Profile"
    assert_dom "a", "Email"
    assert_dom "a", "Password"
    assert_dom "a", "Account"
  end
end
