class AddTopicToSigns < ActiveRecord::Migration[6.0]
  def change
    add_reference :signs, :topic, null: true, foreign_key: true
  end
end
