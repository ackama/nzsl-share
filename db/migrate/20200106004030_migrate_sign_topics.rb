class MigrateSignTopics < ActiveRecord::Migration[6.0]
  def up
    Sign.where.not(topic_id: nil).each do |sign|
      execute("INSERT INTO sign_topics(topic_id, sign_id, created_at, updated_at) VALUES (#{sign.topic_id}, #{sign.id}, NOW(), NOW());")
    end

    remove_column :signs, :topic_id
  end

  def down
    add_column :signs, :topic_id, :integer
  end
end
