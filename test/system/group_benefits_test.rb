require "application_system_test_case"

class GroupBenefitsTest < ApplicationSystemTestCase
  setup do
    @group_benefit = group_benefits(:one)
  end

  test "visiting the index" do
    visit group_benefits_url
    assert_selector "h1", text: "Group benefits"
  end

  test "should create group benefit" do
    visit group_benefits_url
    click_on "New group benefit"

    fill_in "Amount benefit", with: @group_benefit.amount_benefit
    fill_in "Benefit", with: @group_benefit.benefit_id
    fill_in "Relationship", with: @group_benefit.relationship
    fill_in "Residency from", with: @group_benefit.residency_from
    fill_in "Residency to", with: @group_benefit.residency_to
    click_on "Create Group benefit"

    assert_text "Group benefit was successfully created"
    click_on "Back"
  end

  test "should update Group benefit" do
    visit group_benefit_url(@group_benefit)
    click_on "Edit this group benefit", match: :first

    fill_in "Amount benefit", with: @group_benefit.amount_benefit
    fill_in "Benefit", with: @group_benefit.benefit_id
    fill_in "Relationship", with: @group_benefit.relationship
    fill_in "Residency from", with: @group_benefit.residency_from
    fill_in "Residency to", with: @group_benefit.residency_to
    click_on "Update Group benefit"

    assert_text "Group benefit was successfully updated"
    click_on "Back"
  end

  test "should destroy Group benefit" do
    visit group_benefit_url(@group_benefit)
    click_on "Destroy this group benefit", match: :first

    assert_text "Group benefit was successfully destroyed"
  end
end
