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

ActiveRecord::Schema[7.0].define(version: 2024_11_13_172740) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "federal_districts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_federal_districts_on_name", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "federal_district_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["federal_district_id"], name: "index_regions_on_federal_district_id"
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "login", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "fio", null: false
    t.boolean "admin", default: false, null: false
    t.bigint "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["region_id"], name: "index_users_on_region_id"
  end

  add_foreign_key "regions", "federal_districts"
  add_foreign_key "users", "regions"
end
