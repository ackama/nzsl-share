class SignTopicJoiningTable < ActiveRecord::Migration[6.0]
  def change
    create_table :sign_topics do |t|
      t.belongs_to :topic, null: false, foreign_key: true
      t.belongs_to :sign, null: false, foreign_key: true
      t.timestamps
    end

    add_index :sign_topics, %i[topic_id sign_id], unique: true
  end
end
