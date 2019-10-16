class AddSignsCounterCacheToFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :folders, :signs_count, :integer, default: 0
  end
end
