# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_21_091806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "folder_memberships", force: :cascade do |t|
    t.bigint "folder_id", null: false
    t.bigint "sign_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["folder_id", "sign_id"], name: "index_folder_memberships_on_folder_id_and_sign_id", unique: true
    t.index ["folder_id"], name: "index_folder_memberships_on_folder_id"
    t.index ["sign_id"], name: "index_folder_memberships_on_sign_id"
  end

  create_table "folders", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "share_token", limit: 100
    t.integer "signs_count", default: 0
    t.index "user_id, btrim(lower((title)::text))", name: "user_folders_title_unique_idx", unique: true
    t.index ["share_token"], name: "index_folders_on_share_token"
    t.index ["user_id", "title"], name: "index_folders_on_user_id_and_title", unique: true
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "freelex_signs", id: :integer, default: nil, force: :cascade do |t|
    t.string "word", limit: 512, null: false
    t.string "maori", limit: 512
    t.string "secondary", limit: 512
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.index ["maori"], name: "idx_freelex_signs_maori"
    t.index ["secondary"], name: "idx_freelex_signs_secondary"
    t.index ["word"], name: "idx_freelex_signs_word"
  end

  create_table "signs", id: :serial, force: :cascade do |t|
    t.string "word", limit: 256, null: false
    t.string "maori", limit: 256
    t.string "secondary", limit: 256
    t.datetime "published_at"
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.bigint "contributor_id", null: false
    t.bigint "topic_id"
    t.text "description"
    t.text "notes"
    t.boolean "processed_videos", default: false, null: false
    t.boolean "processed_thumbnails", default: false, null: false
    t.index ["contributor_id"], name: "index_signs_on_contributor_id"
    t.index ["maori"], name: "idx_signs_maori"
    t.index ["notes"], name: "index_signs_on_notes"
    t.index ["secondary"], name: "idx_signs_secondary"
    t.index ["topic_id"], name: "index_signs_on_topic_id"
    t.index ["word"], name: "idx_signs_word"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "featured_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["featured_at"], name: "index_topics_on_featured_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "folder_memberships", "folders"
  add_foreign_key "folder_memberships", "signs"
  add_foreign_key "signs", "topics"
  add_foreign_key "signs", "users", column: "contributor_id"
end
