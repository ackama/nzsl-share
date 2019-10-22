class AddProcessingStatusColumnsToSigns < ActiveRecord::Migration[6.0]
  def change
    change_table :signs, bulk: true do |t|
      t.boolean :processed_videos, default: false, null: false
      t.boolean :processed_thumbnails, default: false, null: false
    end
  end
end
