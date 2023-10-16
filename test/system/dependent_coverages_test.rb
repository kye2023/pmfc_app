require "application_system_test_case"

class DependentCoveragesTest < ApplicationSystemTestCase
  setup do
    @dependent_coverage = dependent_coverages(:one)
  end

  test "visiting the index" do
    visit dependent_coverages_url
    assert_selector "h1", text: "Dependent coverages"
  end

  test "should create dependent coverage" do
    visit dependent_coverages_url
    click_on "New dependent coverage"

    fill_in "Coverage", with: @dependent_coverage.coverage_id
    fill_in "Dependent", with: @dependent_coverage.dependent_id
    fill_in "Group coverage", with: @dependent_coverage.group_coverage
    fill_in "Group premium", with: @dependent_coverage.group_premium
    fill_in "Member", with: @dependent_coverage.member_id
    fill_in "Residency", with: @dependent_coverage.residency
    fill_in "Term", with: @dependent_coverage.term
    click_on "Create Dependent coverage"

    assert_text "Dependent coverage was successfully created"
    click_on "Back"
  end

  test "should update Dependent coverage" do
    visit dependent_coverage_url(@dependent_coverage)
    click_on "Edit this dependent coverage", match: :first

    fill_in "Coverage", with: @dependent_coverage.coverage_id
    fill_in "Dependent", with: @dependent_coverage.dependent_id
    fill_in "Group coverage", with: @dependent_coverage.group_coverage
    fill_in "Group premium", with: @dependent_coverage.group_premium
    fill_in "Member", with: @dependent_coverage.member_id
    fill_in "Residency", with: @dependent_coverage.residency
    fill_in "Term", with: @dependent_coverage.term
    click_on "Update Dependent coverage"

    assert_text "Dependent coverage was successfully updated"
    click_on "Back"
  end

  test "should destroy Dependent coverage" do
    visit dependent_coverage_url(@dependent_coverage)
    click_on "Destroy this dependent coverage", match: :first

    assert_text "Dependent coverage was successfully destroyed"
  end
end
