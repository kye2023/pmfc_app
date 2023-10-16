require "test_helper"

class CoveragesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coverage = coverages(:one)
  end

  test "should get index" do
    get coverages_url
    assert_response :success
  end

  test "should get new" do
    get new_coverage_url
    assert_response :success
  end

  test "should create coverage" do
    assert_difference("Coverage.count") do
      post coverages_url, params: { coverage: { age: @coverage.age, batch_id: @coverage.batch_id, effectivity: @coverage.effectivity, expiry: @coverage.expiry, group_certificate: @coverage.group_certificate, group_coverage: @coverage.group_coverage, group_premium: @coverage.group_premium, loan_certificate: @coverage.loan_certificate, lppi_gross_premium: @coverage.lppi_gross_premium, member_id: @coverage.member_id, residency: @coverage.residency, status: @coverage.status, term: @coverage.term } }
    end

    assert_redirected_to coverage_url(Coverage.last)
  end

  test "should show coverage" do
    get coverage_url(@coverage)
    assert_response :success
  end

  test "should get edit" do
    get edit_coverage_url(@coverage)
    assert_response :success
  end

  test "should update coverage" do
    patch coverage_url(@coverage), params: { coverage: { age: @coverage.age, batch_id: @coverage.batch_id, effectivity: @coverage.effectivity, expiry: @coverage.expiry, group_certificate: @coverage.group_certificate, group_coverage: @coverage.group_coverage, group_premium: @coverage.group_premium, loan_certificate: @coverage.loan_certificate, lppi_gross_premium: @coverage.lppi_gross_premium, member_id: @coverage.member_id, residency: @coverage.residency, status: @coverage.status, term: @coverage.term } }
    assert_redirected_to coverage_url(@coverage)
  end

  test "should destroy coverage" do
    assert_difference("Coverage.count", -1) do
      delete coverage_url(@coverage)
    end

    assert_redirected_to coverages_url
  end
end
