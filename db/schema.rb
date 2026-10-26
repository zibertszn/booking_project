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

ActiveRecord::Schema[8.1].define(version: 2026_10_26_000102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "resource_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "booking_period", type: :tsrange, as: "tsrange(starts_at, ends_at, '[)'::text)", stored: true
    t.index ["resource_id", "starts_at"], name: "index_bookings_on_resource_id_and_starts_at"
    t.index ["resource_id"], name: "index_bookings_on_resource_id"
    t.index ["user_id", "starts_at"], name: "index_bookings_on_user_id_and_starts_at"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.check_constraint "ends_at > starts_at", name: "bookings_end_after_start"
    t.exclusion_constraint "resource_id WITH =, booking_period WITH &&", using: :gist, name: "bookings_no_resource_overlap"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "resource_type", null: false
    t.index ["name"], name: "index_resources_on_name", unique: true
    t.index ["user_id"], name: "index_resources_on_user_id"
    t.check_constraint "resource_type::text = ANY (ARRAY['property'::character varying, 'item'::character varying]::text[])", name: "resources_resource_type_valid"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "resources"
  add_foreign_key "bookings", "users"
  add_foreign_key "resources", "users"
end
