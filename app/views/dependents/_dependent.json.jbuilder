json.extract! dependent, :id, :member_id, :last_name, :first_name, :middle_name, :birth_date, :civil_status, :gender, :mobile_no, :email, :relationship, :created_at, :updated_at
json.url dependent_url(dependent, format: :json)
