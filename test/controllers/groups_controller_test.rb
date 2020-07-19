require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get groups_new_url
    assert_response :success
  end

  test "should get manage" do
    get groups_manage_url
    assert_response :success
  end

end
