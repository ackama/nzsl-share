class RenameEnglishToWordOnFreelexSigns < ActiveRecord::Migration[6.0]
  def change
    rename_column :freelex_signs, :english, :word
  end
end
