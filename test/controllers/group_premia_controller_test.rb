require "test_helper"

class GroupPremiaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group_premium = group_premia(:one)
  end

  test "should get index" do
    get group_premia_url
    assert_response :success
  end

  test "should get new" do
    get new_group_premium_url
    assert_response :success
  end

  test "should create group_premium" do
    assert_difference("GroupPremium.count") do
      post group_premia_url, params: { group_premium: { amount_premium: @group_premium.amount_premium, relationship: @group_premium.relationship, residency_from: @group_premium.residency_from, residency_to: @group_premium.residency_to, term_coverage: @group_premium.term_coverage } }
    end

    assert_redirected_to group_premium_url(GroupPremium.last)
  end

  test "should show group_premium" do
    get group_premium_url(@group_premium)
    assert_response :success
  end

  test "should get edit" do
    get edit_group_premium_url(@group_premium)
    assert_response :success
  end

  test "should update group_premium" do
    patch group_premium_url(@group_premium), params: { group_premium: { amount_premium: @group_premium.amount_premium, relationship: @group_premium.relationship, residency_from: @group_premium.residency_from, residency_to: @group_premium.residency_to, term_coverage: @group_premium.term_coverage } }
    assert_redirected_to group_premium_url(@group_premium)
  end

  test "should destroy group_premium" do
    assert_difference("GroupPremium.count", -1) do
      delete group_premium_url(@group_premium)
    end

    assert_redirected_to group_premia_url
  end
end
