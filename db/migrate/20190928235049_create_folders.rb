class CreateFolders < ActiveRecord::Migration[6.0]
  def change
    create_table :folders do |t|
      t.string :title, null: false, default: ""
      t.text :description
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
