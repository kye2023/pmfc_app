require "application_system_test_case"

class GroupPremiaTest < ApplicationSystemTestCase
  setup do
    @group_premium = group_premia(:one)
  end

  test "visiting the index" do
    visit group_premia_url
    assert_selector "h1", text: "Group premia"
  end

  test "should create group premium" do
    visit group_premia_url
    click_on "New group premium"

    fill_in "Amount premium", with: @group_premium.amount_premium
    fill_in "Relationship", with: @group_premium.relationship
    fill_in "Residency from", with: @group_premium.residency_from
    fill_in "Residency to", with: @group_premium.residency_to
    fill_in "Term coverage", with: @group_premium.term_coverage
    click_on "Create Group premium"

    assert_text "Group premium was successfully created"
    click_on "Back"
  end

  test "should update Group premium" do
    visit group_premium_url(@group_premium)
    click_on "Edit this group premium", match: :first

    fill_in "Amount premium", with: @group_premium.amount_premium
    fill_in "Relationship", with: @group_premium.relationship
    fill_in "Residency from", with: @group_premium.residency_from
    fill_in "Residency to", with: @group_premium.residency_to
    fill_in "Term coverage", with: @group_premium.term_coverage
    click_on "Update Group premium"

    assert_text "Group premium was successfully updated"
    click_on "Back"
  end

  test "should destroy Group premium" do
    visit group_premium_url(@group_premium)
    click_on "Destroy this group premium", match: :first

    assert_text "Group premium was successfully destroyed"
  end
end
