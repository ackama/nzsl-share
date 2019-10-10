class AddUniquenessConstraintToFolderNames < ActiveRecord::Migration[6.0]
  def change
    add_index :folders, %i[user_id title], unique: true
  end
end
