class CreateSignActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :sign_activities do |t|
      t.string :key, null: false, index: true
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :sign, null: false, foreign_key: true

      t.timestamps
    end

    # These indexes make looking up agreements and disagreements fast,
    # but also introduce a constraint so that a user can only agree
    # or disagree on a sign once.
    add_index :sign_activities,
              %i[user_id sign_id],
              name: :sign_agreements,
              unique: true,
              where: "key = '#{SignActivity::ACTIVITY_AGREE}'"

    add_index :sign_activities,
              %i[user_id sign_id],
              name: :sign_disagreements,
              unique: true,
              where: "key = '#{SignActivity::ACTIVITY_DISAGREE}'"
  end
end
