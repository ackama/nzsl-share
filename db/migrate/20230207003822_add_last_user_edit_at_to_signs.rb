class AddLastUserEditAtToSigns < ActiveRecord::Migration[6.1]
  def up
    add_column :signs, :last_user_edit_at, :timestamp
    execute "UPDATE signs SET last_user_edit_at=updated_at"
  end

  def down
    remove_column :signs, :last_user_edit_at, :timestamp
  end
end
