class AddUrlPathToFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :folders, :share_token, :string, limit: 100
  end
end
