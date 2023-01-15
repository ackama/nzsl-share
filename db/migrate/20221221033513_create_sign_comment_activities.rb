class CreateSignCommentActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :sign_comment_activities do |t|
      t.belongs_to :sign_comment, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.string :key, null: false, index: true

      t.timestamps
    end

    add_index :sign_comment_activities, %i[sign_comment_id user_id key], name: :idx_sign_comment_activities
  end
end
