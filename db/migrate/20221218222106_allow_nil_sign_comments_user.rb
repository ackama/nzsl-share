class AllowNilSignCommentsUser < ActiveRecord::Migration[6.1]
  def change
    change_column_null :sign_comments, :user_id, from: false, to: true
  end
end
