require "test_helper"

class ApodsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apods_index_url
    assert_response :success
  end

  test "should get search" do
    get apods_search_url
    assert_response :success
  end
end
