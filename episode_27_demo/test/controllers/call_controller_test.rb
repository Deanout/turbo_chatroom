require "test_helper"

class CallControllerTest < ActionDispatch::IntegrationTest
  test "should get user" do
    get call_user_url
    assert_response :success
  end
end
