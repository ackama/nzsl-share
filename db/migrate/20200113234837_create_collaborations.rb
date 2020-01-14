class CreateCollaborations < ActiveRecord::Migration[6.0]
  def change
    create_table :collaborations do |t|
      t.belongs_to :folder, null: false, foreign_key: true
      t.belongs_to :collaborator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :collaborations, %i[folder_id collaborator_id], unique: true
  end
end
