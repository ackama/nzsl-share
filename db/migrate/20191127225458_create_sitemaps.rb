class CreateSitemaps < ActiveRecord::Migration[6.0]
  def change
    create_table :sitemaps do |t|
      t.text :xml, null: false
      t.timestamps
    end

    add_index :sitemaps, :created_at
  end
end
