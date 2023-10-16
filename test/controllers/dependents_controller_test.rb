require "test_helper"

class DependentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dependent = dependents(:one)
  end

  test "should get index" do
    get dependents_url
    assert_response :success
  end

  test "should get new" do
    get new_dependent_url
    assert_response :success
  end

  test "should create dependent" do
    assert_difference("Dependent.count") do
      post dependents_url, params: { dependent: { birth_date: @dependent.birth_date, civil_status: @dependent.civil_status, email: @dependent.email, first_name: @dependent.first_name, gender: @dependent.gender, last_name: @dependent.last_name, member_id: @dependent.member_id, middle_name: @dependent.middle_name, mobile_no: @dependent.mobile_no, relationship: @dependent.relationship } }
    end

    assert_redirected_to dependent_url(Dependent.last)
  end

  test "should show dependent" do
    get dependent_url(@dependent)
    assert_response :success
  end

  test "should get edit" do
    get edit_dependent_url(@dependent)
    assert_response :success
  end

  test "should update dependent" do
    patch dependent_url(@dependent), params: { dependent: { birth_date: @dependent.birth_date, civil_status: @dependent.civil_status, email: @dependent.email, first_name: @dependent.first_name, gender: @dependent.gender, last_name: @dependent.last_name, member_id: @dependent.member_id, middle_name: @dependent.middle_name, mobile_no: @dependent.mobile_no, relationship: @dependent.relationship } }
    assert_redirected_to dependent_url(@dependent)
  end

  test "should destroy dependent" do
    assert_difference("Dependent.count", -1) do
      delete dependent_url(@dependent)
    end

    assert_redirected_to dependents_url
  end
end
