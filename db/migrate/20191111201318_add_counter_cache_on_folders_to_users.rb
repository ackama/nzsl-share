class AddCounterCacheOnFoldersToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :folders_count, :integer, default: 0, null: false
    User.find_each { |u| User.reset_counters(u.id, :folders) }
  end

  def down
    remove_column :users, :folders_count
  end
end
