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

ActiveRecord::Schema.define(version: 2019_09_24_004455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "freelex_signs", id: :integer, default: nil, force: :cascade do |t|
    t.string "english", limit: 512, null: false
    t.string "maori", limit: 512
    t.string "secondary", limit: 512
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.index ["english"], name: "idx_freelex_signs_english"
    t.index ["maori"], name: "idx_freelex_signs_maori"
    t.index ["secondary"], name: "idx_freelex_signs_secondary"
  end

  create_table "signs", id: :serial, force: :cascade do |t|
    t.string "english", limit: 256, null: false
    t.string "maori", limit: 256
    t.string "secondary", limit: 256
    t.datetime "updated_at", null: false
    t.datetime "created_at", null: false
    t.index ["english"], name: "idx_signs_english"
    t.index ["maori"], name: "idx_signs_maori"
    t.index ["secondary"], name: "idx_signs_secondary"
  end

end
