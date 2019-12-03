class UpdateTimestampsOnFreelexSigns < ActiveRecord::Migration[6.0]
  def up
    add_column :freelex_signs, :published_at, :datetime
    FreelexSign.update_all("published_at=created_at")
    change_column_null :freelex_signs, :published_at, false

    change_table :freelex_signs, bulk: true, &:remove_timestamps
  end

  def down
    change_table :freelex_signs, bulk: true do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    FreelexSign.update_all("created_at=published_at, updated_at=published_at")

    change_column_null :freelex_signs, :created_at, false
    change_column_null :freelex_signs, :updated_at, false

    remove_column :freelex_signs, :published_at
  end
end
