class AddSignPublishingDate < ActiveRecord::Migration[6.0]
  def up
    do_down
    do_up_freelex
    do_up_signs
  end

  def down
    do_down
  end

  private

  def do_up_freelex
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
  end

  def do_up_signs
    create_table "signs", id: :serial, force: :cascade do |t|
      t.string "english", limit: 256, null: false
      t.string "maori", limit: 256
      t.string "secondary", limit: 256
      t.datetime "published_at"
      t.datetime "updated_at", null: false
      t.datetime "created_at", null: false
      t.index ["english"], name: "idx_signs_english"
      t.index ["maori"], name: "idx_signs_maori"
      t.index ["secondary"], name: "idx_signs_secondary"
    end
  end

  def do_down
    drop_table "freelex_signs"
    drop_table "signs"
  end
end
