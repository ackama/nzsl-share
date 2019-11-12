class AddUserRoleFlagsToUsers < ActiveRecord::Migration[6.0]
  def change
    with_options null: false, default: false do
      add_column :users, :administrator, :boolean
      add_column :users, :moderator, :boolean
      add_column :users, :approved, :boolean
      add_column :users, :validator, :boolean
    end
  end
end
