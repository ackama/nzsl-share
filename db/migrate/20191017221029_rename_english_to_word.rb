class RenameEnglishToWord < ActiveRecord::Migration[6.0]
  def change
    rename_column :signs, :english, :word
  end
end
