require "application_system_test_case"

class CoveragesTest < ApplicationSystemTestCase
  setup do
    @coverage = coverages(:one)
  end

  test "visiting the index" do
    visit coverages_url
    assert_selector "h1", text: "Coverages"
  end

  test "should create coverage" do
    visit coverages_url
    click_on "New coverage"

    fill_in "Age", with: @coverage.age
    fill_in "Batch", with: @coverage.batch_id
    fill_in "Effectivity", with: @coverage.effectivity
    fill_in "Expiry", with: @coverage.expiry
    fill_in "Group certificate", with: @coverage.group_certificate
    fill_in "Group coverage", with: @coverage.group_coverage
    fill_in "Group premium", with: @coverage.group_premium
    fill_in "Loan certificate", with: @coverage.loan_certificate
    fill_in "Lppi gross premium", with: @coverage.lppi_gross_premium
    fill_in "Member", with: @coverage.member_id
    fill_in "Residency", with: @coverage.residency
    fill_in "Status", with: @coverage.status
    fill_in "Term", with: @coverage.term
    click_on "Create Coverage"

    assert_text "Coverage was successfully created"
    click_on "Back"
  end

  test "should update Coverage" do
    visit coverage_url(@coverage)
    click_on "Edit this coverage", match: :first

    fill_in "Age", with: @coverage.age
    fill_in "Batch", with: @coverage.batch_id
    fill_in "Effectivity", with: @coverage.effectivity
    fill_in "Expiry", with: @coverage.expiry
    fill_in "Group certificate", with: @coverage.group_certificate
    fill_in "Group coverage", with: @coverage.group_coverage
    fill_in "Group premium", with: @coverage.group_premium
    fill_in "Loan certificate", with: @coverage.loan_certificate
    fill_in "Lppi gross premium", with: @coverage.lppi_gross_premium
    fill_in "Member", with: @coverage.member_id
    fill_in "Residency", with: @coverage.residency
    fill_in "Status", with: @coverage.status
    fill_in "Term", with: @coverage.term
    click_on "Update Coverage"

    assert_text "Coverage was successfully updated"
    click_on "Back"
  end

  test "should destroy Coverage" do
    visit coverage_url(@coverage)
    click_on "Destroy this coverage", match: :first

    assert_text "Coverage was successfully destroyed"
  end
end
