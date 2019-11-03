class SignsShareToken < ActiveRecord::Migration[6.0]
  def change
    remove_column :folders, :share_token, :string if column_exists?(:folders, :share_token)
    remove_column :signs, :share_token, :string if column_exists?(:signs, :share_token)

    add_column :folders, :share_token, :string
    add_column :signs, :share_token, :string

    add_index :folders, :share_token, unique: true
    add_index :signs, :share_token, unique: true
  end
end
