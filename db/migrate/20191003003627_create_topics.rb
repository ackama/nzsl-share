class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.string :name, null: false, unique: true
      t.datetime :featured_at, index: true

      t.timestamps
    end
  end
end
