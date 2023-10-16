json.extract! member, :id, :member_id, :last_name, :first_name, :middle_name, :birth_date, :date_membership, :civil_status, :gender, :mobile_no, :email, :created_at, :updated_at
json.url member_url(member, format: :json)
