class RemoveFreelexSignsTable < ActiveRecord::Migration[6.1]
  def change
    # From db/schema.rb
    drop_table :freelex_signs do |t|
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
  end
end
