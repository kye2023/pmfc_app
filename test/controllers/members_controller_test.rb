require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = members(:one)
  end

  test "should get index" do
    get members_url
    assert_response :success
  end

  test "should get new" do
    get new_member_url
    assert_response :success
  end

  test "should create member" do
    assert_difference("Member.count") do
      post members_url, params: { member: { birth_date: @member.birth_date, civil_status: @member.civil_status, date_membership: @member.date_membership, email: @member.email, first_name: @member.first_name, gender: @member.gender, last_name: @member.last_name, member_id: @member.member_id, middle_name: @member.middle_name, mobile_no: @member.mobile_no } }
    end

    assert_redirected_to member_url(Member.last)
  end

  test "should show member" do
    get member_url(@member)
    assert_response :success
  end

  test "should get edit" do
    get edit_member_url(@member)
    assert_response :success
  end

  test "should update member" do
    patch member_url(@member), params: { member: { birth_date: @member.birth_date, civil_status: @member.civil_status, date_membership: @member.date_membership, email: @member.email, first_name: @member.first_name, gender: @member.gender, last_name: @member.last_name, member_id: @member.member_id, middle_name: @member.middle_name, mobile_no: @member.mobile_no } }
    assert_redirected_to member_url(@member)
  end

  test "should destroy member" do
    assert_difference("Member.count", -1) do
      delete member_url(@member)
    end

    assert_redirected_to members_url
  end
end
