class AddLastUserEditAtToSigns < ActiveRecord::Migration[6.1]
  def change
    add_column :signs, :last_user_edit_at, :timestamp
  end
end
