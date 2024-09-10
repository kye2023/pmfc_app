require "application_system_test_case"

class CenterNamesTest < ApplicationSystemTestCase
  setup do
    @center_name = center_names(:one)
  end

  test "visiting the index" do
    visit center_names_url
    assert_selector "h1", text: "Center names"
  end

  test "should create center name" do
    visit center_names_url
    click_on "New center name"

    fill_in "Description", with: @center_name.description
    click_on "Create Center name"

    assert_text "Center name was successfully created"
    click_on "Back"
  end

  test "should update Center name" do
    visit center_name_url(@center_name)
    click_on "Edit this center name", match: :first

    fill_in "Description", with: @center_name.description
    click_on "Update Center name"

    assert_text "Center name was successfully updated"
    click_on "Back"
  end

  test "should destroy Center name" do
    visit center_name_url(@center_name)
    click_on "Destroy this center name", match: :first

    assert_text "Center name was successfully destroyed"
  end
end
