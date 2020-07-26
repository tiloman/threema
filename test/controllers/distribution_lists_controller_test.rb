require 'test_helper'

class DistributionListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get distribution_lists_index_url
    assert_response :success
  end

  test "should get edit" do
    get distribution_lists_edit_url
    assert_response :success
  end

end
