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
      post group_benefits_url, params: { group_benefit: { add: @group_benefit.add, burial: @group_benefit.burial, life: @group_benefit.life, member_type: @group_benefit.member_type, residency_ceiling: @group_benefit.residency_ceiling, residency_floor: @group_benefit.residency_floor } }
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
    patch group_benefit_url(@group_benefit), params: { group_benefit: { add: @group_benefit.add, burial: @group_benefit.burial, life: @group_benefit.life, member_type: @group_benefit.member_type, residency_ceiling: @group_benefit.residency_ceiling, residency_floor: @group_benefit.residency_floor } }
    assert_redirected_to group_benefit_url(@group_benefit)
  end

  test "should destroy group_benefit" do
    assert_difference("GroupBenefit.count", -1) do
      delete group_benefit_url(@group_benefit)
    end

    assert_redirected_to group_benefits_url
  end
end
