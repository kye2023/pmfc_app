json.extract! user_detail, :id, :user_id, :last_name, :first_name, :middle_initial, :gender, :contact_no, :created_at, :updated_at
json.url user_detail_url(user_detail, format: :json)
