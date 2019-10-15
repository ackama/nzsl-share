class RebuildUniqueIndexOnFolderTitleForSpacingAndCase < ActiveRecord::Migration[6.0]
  def change
    # execute <<~SQL
    #   ADD UNIQUE INDEX folders_title_unique_idx ON folders (TRIM(BOTH FROM LOWER(title)))
    # SQL
    add_index :folders,
              "user_id, TRIM(BOTH FROM LOWER(title))",
              unique: true,
              name: :user_folders_title_unique_idx
  end
end
