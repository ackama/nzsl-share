class RenameIndicesFromEnglishToWord < ActiveRecord::Migration[6.0]
  def change
    rename_index :signs, "idx_signs_english", "idx_signs_word"
    rename_index :freelex_signs, "idx_freelex_signs_english", "idx_freelex_signs_word"
  end
end
