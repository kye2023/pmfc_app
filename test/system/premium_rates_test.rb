require "application_system_test_case"

class PremiumRatesTest < ApplicationSystemTestCase
  setup do
    @premium_rate = premium_rates(:one)
  end

  test "visiting the index" do
    visit premium_rates_url
    assert_selector "h1", text: "Premium rates"
  end

  test "should create premium rate" do
    visit premium_rates_url
    click_on "New premium rate"

    fill_in "Batch", with: @premium_rate.batch_id
    fill_in "Premium", with: @premium_rate.premium
    click_on "Create Premium rate"

    assert_text "Premium rate was successfully created"
    click_on "Back"
  end

  test "should update Premium rate" do
    visit premium_rate_url(@premium_rate)
    click_on "Edit this premium rate", match: :first

    fill_in "Batch", with: @premium_rate.batch_id
    fill_in "Premium", with: @premium_rate.premium
    click_on "Update Premium rate"

    assert_text "Premium rate was successfully updated"
    click_on "Back"
  end

  test "should destroy Premium rate" do
    visit premium_rate_url(@premium_rate)
    click_on "Destroy this premium rate", match: :first

    assert_text "Premium rate was successfully destroyed"
  end
end
