require "test_helper"

class GroupBenefitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group_benefit = group_benefits(:one)
  end

  test "should get index" do
    get group_benefits_url
    assert_response :success
  end

  test "should get new" do
    get new_group_benefit_url
    assert_response :success
  end

  test "should create group_benefit" do
    assert_difference("GroupBenefit.count") do
      post group_benefits_url, params: { group_benefit: { amount_benefit: @group_benefit.amount_benefit, benefit_id: @group_benefit.benefit_id, relationship: @group_benefit.relationship, residency_from: @group_benefit.residency_from, residency_to: @group_benefit.residency_to } }
    end

    assert_redirected_to group_benefit_url(GroupBenefit.last)
  end

  test "should show group_benefit" do
    get group_benefit_url(@group_benefit)
    assert_response :success
  end

  test "should get edit" do
    get edit_group_benefit_url(@group_benefit)
    assert_response :success
  end

  test "should update group_benefit" do
    patch group_benefit_url(@group_benefit), params: { group_benefit: { amount_benefit: @group_benefit.amount_benefit, benefit_id: @group_benefit.benefit_id, relationship: @group_benefit.relationship, residency_from: @group_benefit.residency_from, residency_to: @group_benefit.residency_to } }
    assert_redirected_to group_benefit_url(@group_benefit)
  end

  test "should destroy group_benefit" do
    assert_difference("GroupBenefit.count", -1) do
      delete group_benefit_url(@group_benefit)
    end

    assert_redirected_to group_benefits_url
  end
end
