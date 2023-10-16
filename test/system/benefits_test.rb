require "application_system_test_case"

class BenefitsTest < ApplicationSystemTestCase
  setup do
    @benefit = benefits(:one)
  end

  test "visiting the index" do
    visit benefits_url
    assert_selector "h1", text: "Benefits"
  end

  test "should create benefit" do
    visit benefits_url
    click_on "New benefit"

    fill_in "Description", with: @benefit.description
    fill_in "Name", with: @benefit.name
    click_on "Create Benefit"

    assert_text "Benefit was successfully created"
    click_on "Back"
  end

  test "should update Benefit" do
    visit benefit_url(@benefit)
    click_on "Edit this benefit", match: :first

    fill_in "Description", with: @benefit.description
    fill_in "Name", with: @benefit.name
    click_on "Update Benefit"

    assert_text "Benefit was successfully updated"
    click_on "Back"
  end

  test "should destroy Benefit" do
    visit benefit_url(@benefit)
    click_on "Destroy this benefit", match: :first

    assert_text "Benefit was successfully destroyed"
  end
end
