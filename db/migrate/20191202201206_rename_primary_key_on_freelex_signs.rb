class RenamePrimaryKeyOnFreelexSigns < ActiveRecord::Migration[6.0]
  def change
    rename_column :freelex_signs, :id, :headword_id
    add_index :freelex_signs, :headword_id, unique: true
  end
end
