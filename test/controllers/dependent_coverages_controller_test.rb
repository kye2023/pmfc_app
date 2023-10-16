require "test_helper"

class DependentCoveragesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dependent_coverage = dependent_coverages(:one)
  end

  test "should get index" do
    get dependent_coverages_url
    assert_response :success
  end

  test "should get new" do
    get new_dependent_coverage_url
    assert_response :success
  end

  test "should create dependent_coverage" do
    assert_difference("DependentCoverage.count") do
      post dependent_coverages_url, params: { dependent_coverage: { coverage_id: @dependent_coverage.coverage_id, dependent_id: @dependent_coverage.dependent_id, group_coverage: @dependent_coverage.group_coverage, group_premium: @dependent_coverage.group_premium, member_id: @dependent_coverage.member_id, residency: @dependent_coverage.residency, term: @dependent_coverage.term } }
    end

    assert_redirected_to dependent_coverage_url(DependentCoverage.last)
  end

  test "should show dependent_coverage" do
    get dependent_coverage_url(@dependent_coverage)
    assert_response :success
  end

  test "should get edit" do
    get edit_dependent_coverage_url(@dependent_coverage)
    assert_response :success
  end

  test "should update dependent_coverage" do
    patch dependent_coverage_url(@dependent_coverage), params: { dependent_coverage: { coverage_id: @dependent_coverage.coverage_id, dependent_id: @dependent_coverage.dependent_id, group_coverage: @dependent_coverage.group_coverage, group_premium: @dependent_coverage.group_premium, member_id: @dependent_coverage.member_id, residency: @dependent_coverage.residency, term: @dependent_coverage.term } }
    assert_redirected_to dependent_coverage_url(@dependent_coverage)
  end

  test "should destroy dependent_coverage" do
    assert_difference("DependentCoverage.count", -1) do
      delete dependent_coverage_url(@dependent_coverage)
    end

    assert_redirected_to dependent_coverages_url
  end
end
