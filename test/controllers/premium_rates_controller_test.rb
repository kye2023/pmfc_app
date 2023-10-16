require "test_helper"

class PremiumRatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @premium_rate = premium_rates(:one)
  end

  test "should get index" do
    get premium_rates_url
    assert_response :success
  end

  test "should get new" do
    get new_premium_rate_url
    assert_response :success
  end

  test "should create premium_rate" do
    assert_difference("PremiumRate.count") do
      post premium_rates_url, params: { premium_rate: { batch_id: @premium_rate.batch_id, premium: @premium_rate.premium } }
    end

    assert_redirected_to premium_rate_url(PremiumRate.last)
  end

  test "should show premium_rate" do
    get premium_rate_url(@premium_rate)
    assert_response :success
  end

  test "should get edit" do
    get edit_premium_rate_url(@premium_rate)
    assert_response :success
  end

  test "should update premium_rate" do
    patch premium_rate_url(@premium_rate), params: { premium_rate: { batch_id: @premium_rate.batch_id, premium: @premium_rate.premium } }
    assert_redirected_to premium_rate_url(@premium_rate)
  end

  test "should destroy premium_rate" do
    assert_difference("PremiumRate.count", -1) do
      delete premium_rate_url(@premium_rate)
    end

    assert_redirected_to premium_rates_url
  end
end
