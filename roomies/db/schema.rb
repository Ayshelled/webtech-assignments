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

ActiveRecord::Schema[8.1].define(version: 2026_10_04_120012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "amenity_category", ["amenity", "shared_space"]
  create_enum "application_status", ["pending", "shortlisted", "accepted", "rejected", "withdrawn"]
  create_enum "listing_status", ["draft", "published", "reserved", "rented", "withdrawn"]
  create_enum "property_type", ["apartment", "house", "studio", "townhouse"]
  create_enum "report_reason", ["fraudulent", "misleading", "offensive", "other"]
  create_enum "report_status", ["pending", "dismissed", "actioned"]
  create_enum "user_role", ["member", "moderator"]
  create_enum "visit_status", ["proposed", "confirmed", "cancelled", "completed"]

  create_table "amenities", force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.enum "category", default: "amenity", null: false, enum_type: "amenity_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.text "message", null: false
    t.date "desired_move_in_date", null: false
    t.integer "intended_stay_months", null: false
    t.enum "status", default: "pending", null: false, enum_type: "application_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "user_id"], name: "index_applications_on_listing_id_and_user_id", unique: true
    t.index ["status"], name: "index_applications_on_status"
    t.index ["user_id"], name: "index_applications_on_user_id"
    t.check_constraint "intended_stay_months >= 1", name: "applications_intended_stay_positive"
  end

  create_table "listing_photos", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.string "caption", limit: 150
    t.string "alt_text", limit: 255
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "position"], name: "index_listing_photos_on_listing_id_and_position"
    t.check_constraint "\"position\" >= 0", name: "listing_photos_position_not_negative"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.enum "status", default: "draft", null: false, enum_type: "listing_status"
    t.decimal "monthly_rent", precision: 10, scale: 2, null: false
    t.decimal "deposit", precision: 10, scale: 2, default: "0.0", null: false
    t.date "available_from", null: false
    t.integer "minimum_stay_months", default: 1, null: false
    t.boolean "furnished", default: false, null: false
    t.boolean "private_bathroom", default: false, null: false
    t.text "description", null: false
    t.text "house_rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_from"], name: "index_listings_on_available_from"
    t.index ["property_id"], name: "index_listings_on_property_id"
    t.index ["status"], name: "index_listings_on_status"
    t.check_constraint "deposit >= 0::numeric", name: "listings_deposit_not_negative"
    t.check_constraint "minimum_stay_months >= 1", name: "listings_minimum_stay_positive"
    t.check_constraint "monthly_rent > 0::numeric", name: "listings_monthly_rent_positive"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "city", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "city"], name: "index_neighborhoods_on_name_and_city", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "street_address", limit: 200, null: false
    t.enum "property_type", null: false, enum_type: "property_type"
    t.integer "bedrooms_count", default: 1, null: false
    t.integer "bathrooms_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id"], name: "index_properties_on_neighborhood_id"
    t.index ["user_id"], name: "index_properties_on_user_id"
    t.check_constraint "bathrooms_count >= 1", name: "properties_bathrooms_count_positive"
    t.check_constraint "bedrooms_count >= 1", name: "properties_bedrooms_count_positive"
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.enum "reason", null: false, enum_type: "report_reason"
    t.text "details"
    t.enum "status", default: "pending", null: false, enum_type: "report_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "user_id"], name: "index_reports_on_listing_id_and_user_id", unique: true
    t.index ["status"], name: "index_reports_on_status"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.integer "rating", null: false
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visit_id"], name: "index_reviews_on_visit_id", unique: true
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_between_1_and_5"
  end

  create_table "saved_listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_saved_listings_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_saved_listings_on_user_id_and_listing_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", limit: 255, null: false
    t.string "password_digest", null: false
    t.string "full_name", limit: 120, null: false
    t.string "phone", limit: 30
    t.enum "role", default: "member", null: false, enum_type: "user_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "scheduled_at", null: false
    t.enum "status", default: "proposed", null: false, enum_type: "visit_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_visits_on_application_id"
  end

  add_foreign_key "applications", "listings"
  add_foreign_key "applications", "users"
  add_foreign_key "listing_photos", "listings"
  add_foreign_key "listings", "properties"
  add_foreign_key "properties", "neighborhoods"
  add_foreign_key "properties", "users"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "reports", "listings"
  add_foreign_key "reports", "users"
  add_foreign_key "reviews", "visits"
  add_foreign_key "saved_listings", "listings"
  add_foreign_key "saved_listings", "users"
  add_foreign_key "visits", "applications"
end
