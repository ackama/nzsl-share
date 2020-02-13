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

ActiveRecord::Schema.define(version: 2020_02_10_004349) do

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

  create_table "approved_user_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "deaf", null: false
    t.boolean "nzsl_first_language", null: false
    t.string "age_bracket"
    t.string "location"
    t.string "gender"
    t.string "ethnicity"
    t.string "language_roles", default: [], array: true
    t.string "subject_expertise"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "submitted"
    t.index ["user_id"], name: "index_approved_user_applications_on_user_id"
  end

  create_table "collaborations", force: :cascade do |t|
    t.bigint "folder_id", null: false
    t.bigint "collaborator_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collaborator_id"], name: "index_collaborations_on_collaborator_id"
    t.index ["folder_id", "collaborator_id"], name: "index_collaborations_on_folder_id_and_collaborator_id", unique: true
    t.index ["folder_id"], name: "index_collaborations_on_folder_id"
  end

  create_table "comment_reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "comment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["comment_id"], name: "index_comment_reports_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_reports_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_comment_reports_on_user_id"
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
    t.integer "signs_count", default: 0
    t.string "share_token"
    t.index "user_id, btrim(lower((title)::text))", name: "user_folders_title_unique_idx", unique: true
    t.index ["share_token"], name: "index_folders_on_share_token", unique: true
    t.index ["user_id", "title"], name: "index_folders_on_user_id_and_title", unique: true
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "freelex_signs", primary_key: "headword_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "word", limit: 512, null: false
    t.string "maori", limit: 512
    t.string "secondary", limit: 512
    t.string "tags", default: [], array: true
    t.datetime "published_at", null: false
    t.string "video_key", default: [], array: true
    t.index ["headword_id"], name: "index_freelex_signs_on_headword_id", unique: true
    t.index ["maori"], name: "idx_freelex_signs_maori"
    t.index ["secondary"], name: "idx_freelex_signs_secondary"
    t.index ["word"], name: "idx_freelex_signs_word"
  end

  create_table "sign_activities", force: :cascade do |t|
    t.string "key", null: false
    t.bigint "user_id", null: false
    t.bigint "sign_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_sign_activities_on_key"
    t.index ["sign_id"], name: "index_sign_activities_on_sign_id"
    t.index ["user_id", "sign_id"], name: "sign_agreements", unique: true, where: "((key)::text = 'agree'::text)"
    t.index ["user_id", "sign_id"], name: "sign_disagreements", unique: true, where: "((key)::text = 'disagree'::text)"
    t.index ["user_id"], name: "index_sign_activities_on_user_id"
  end

  create_table "sign_comments", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "sign_id", null: false
    t.bigint "user_id", null: false
    t.text "comment"
    t.text "sign_status", null: false
    t.boolean "display", default: true
    t.boolean "anonymous", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "folder_id"
    t.boolean "removed", default: false
    t.index ["folder_id"], name: "index_sign_comments_on_folder_id"
    t.index ["parent_id"], name: "index_sign_comments_on_parent_id"
    t.index ["sign_id"], name: "index_sign_comments_on_sign_id"
    t.index ["user_id"], name: "index_sign_comments_on_user_id"
  end

  create_table "sign_topics", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "sign_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sign_id"], name: "index_sign_topics_on_sign_id"
    t.index ["topic_id", "sign_id"], name: "index_sign_topics_on_topic_id_and_sign_id", unique: true
    t.index ["topic_id"], name: "index_sign_topics_on_topic_id"
  end

  create_table "signs", id: :serial, force: :cascade do |t|
    t.string "word", limit: 256, null: false
    t.string "maori", limit: 256
    t.string "secondary", limit: 256
    t.datetime "published_at"
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.bigint "contributor_id", null: false
    t.text "description"
    t.text "notes"
    t.boolean "processed_videos", default: false, null: false
    t.boolean "processed_thumbnails", default: false, null: false
    t.string "share_token"
    t.string "status", null: false
    t.datetime "submitted_at"
    t.datetime "declined_at"
    t.datetime "requested_unpublish_at"
    t.boolean "conditions_accepted", default: false
    t.index ["contributor_id"], name: "index_signs_on_contributor_id"
    t.index ["maori"], name: "idx_signs_maori"
    t.index ["notes"], name: "index_signs_on_notes"
    t.index ["secondary"], name: "idx_signs_secondary"
    t.index ["share_token"], name: "index_signs_on_share_token", unique: true
    t.index ["status"], name: "index_signs_on_status"
    t.index ["word"], name: "idx_signs_word"
  end

  create_table "sitemaps", force: :cascade do |t|
    t.text "xml", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_sitemaps_on_created_at"
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
    t.integer "folders_count", default: 0, null: false
    t.boolean "administrator", default: false, null: false
    t.boolean "moderator", default: false, null: false
    t.boolean "approved", default: false, null: false
    t.boolean "validator", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "contribution_limit", default: 50
    t.text "bio"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "approved_user_applications", "users"
  add_foreign_key "collaborations", "folders"
  add_foreign_key "collaborations", "users", column: "collaborator_id"
  add_foreign_key "comment_reports", "sign_comments", column: "comment_id"
  add_foreign_key "comment_reports", "users"
  add_foreign_key "folder_memberships", "folders"
  add_foreign_key "folder_memberships", "signs"
  add_foreign_key "sign_activities", "signs"
  add_foreign_key "sign_activities", "users"
  add_foreign_key "sign_comments", "signs"
  add_foreign_key "sign_comments", "users"
  add_foreign_key "sign_topics", "signs"
  add_foreign_key "sign_topics", "topics"
  add_foreign_key "signs", "users", column: "contributor_id"
end
