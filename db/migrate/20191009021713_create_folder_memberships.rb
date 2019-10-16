class CreateFolderMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :folder_memberships do |t|
      t.belongs_to :folder, null: false, foreign_key: true
      t.belongs_to :sign, null: false, foreign_key: true

      t.timestamps
    end

    # A sign can't be added to a folder more than once
    add_index :folder_memberships, %i[folder_id sign_id], unique: true
  end
end
