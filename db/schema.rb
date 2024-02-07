# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_24_073802) do
  create_table "batches", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "branch_id"
    t.boolean "submit", default: false
    t.index ["branch_id"], name: "index_batches_on_branch_id"
  end

  create_table "benefits", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.string "contact_no"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coverages", charset: "utf8mb4", force: :cascade do |t|
    t.string "batch_id"
    t.string "member_id"
    t.string "loan_certificate"
    t.integer "age"
    t.date "effectivity"
    t.date "expiry"
    t.integer "term"
    t.string "status"
    t.decimal "loan_premium", precision: 10, scale: 2
    t.decimal "group_premium", precision: 10, scale: 2
    t.string "group_certificate"
    t.string "residency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "loan_coverage", precision: 10, scale: 2
    t.decimal "rate", precision: 10, scale: 2
    t.bigint "group_benefit_id"
    t.decimal "dependent_premium", precision: 10, scale: 2
    t.integer "grace_period"
    t.index ["group_benefit_id"], name: "index_coverages_on_group_benefit_id"
  end

  create_table "dependent_coverages", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "coverage_id"
    t.bigint "dependent_id"
    t.bigint "member_id"
    t.bigint "group_benefit_id"
    t.bigint "batch_id"
    t.decimal "premium", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_dependent_coverages_on_batch_id"
    t.index ["coverage_id"], name: "index_dependent_coverages_on_coverage_id"
    t.index ["dependent_id"], name: "index_dependent_coverages_on_dependent_id"
    t.index ["group_benefit_id"], name: "index_dependent_coverages_on_group_benefit_id"
    t.index ["member_id"], name: "index_dependent_coverages_on_member_id"
  end

  create_table "dependents", charset: "utf8mb4", force: :cascade do |t|
    t.string "member_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.date "birth_date"
    t.string "civil_status"
    t.string "gender"
    t.string "mobile_no"
    t.string "email"
    t.string "relationship"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "suffix"
  end

  create_table "group_benefits", charset: "utf8mb4", force: :cascade do |t|
    t.string "member_type"
    t.integer "residency_floor"
    t.integer "residency_ceiling"
    t.decimal "life", precision: 12, scale: 2
    t.decimal "add", precision: 12, scale: 2
    t.decimal "burial", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_premia", charset: "utf8mb4", force: :cascade do |t|
    t.string "member_type"
    t.integer "term"
    t.integer "residency_floor"
    t.integer "residency_ceiling"
    t.decimal "premium", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", charset: "utf8mb4", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.date "birth_date"
    t.date "date_membership"
    t.string "civil_status"
    t.string "gender"
    t.string "mobile_no"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "suffix"
    t.bigint "branch_id"
    t.string "health_declaration"
    t.index ["branch_id"], name: "index_members_on_branch_id"
  end

  create_table "posts", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "premium_rates", charset: "utf8mb4", force: :cascade do |t|
    t.string "batch_id"
    t.integer "premium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_details", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "branch_id"
    t.string "last_name"
    t.string "first_name"
    t.string "middle_initial"
    t.string "gender"
    t.string "contact_no"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_user_details_on_branch_id"
    t.index ["user_id"], name: "index_user_details_on_user_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false
    t.boolean "admin", default: false
    t.boolean "active", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
