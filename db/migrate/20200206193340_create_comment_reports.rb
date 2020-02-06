class CreateCommentReports < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :comment, null: false, foreign_key: { to_table: :sign_comments }
      t.belongs_to :resolved_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :comment_reports, %i[user_id comment_id], unique: true
  end
end
