require "test_helper"

class CenterNamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @center_name = center_names(:one)
  end

  test "should get index" do
    get center_names_url
    assert_response :success
  end

  test "should get new" do
    get new_center_name_url
    assert_response :success
  end

  test "should create center_name" do
    assert_difference("CenterName.count") do
      post center_names_url, params: { center_name: { description: @center_name.description } }
    end

    assert_redirected_to center_name_url(CenterName.last)
  end

  test "should show center_name" do
    get center_name_url(@center_name)
    assert_response :success
  end

  test "should get edit" do
    get edit_center_name_url(@center_name)
    assert_response :success
  end

  test "should update center_name" do
    patch center_name_url(@center_name), params: { center_name: { description: @center_name.description } }
    assert_redirected_to center_name_url(@center_name)
  end

  test "should destroy center_name" do
    assert_difference("CenterName.count", -1) do
      delete center_name_url(@center_name)
    end

    assert_redirected_to center_names_url
  end
end
