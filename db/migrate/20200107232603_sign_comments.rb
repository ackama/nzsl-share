class SignComments < ActiveRecord::Migration[6.0]
  def change
    create_table :sign_comments do |t|
      t.bigint :parent_id, index: true
      t.belongs_to :sign, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.text :comment
      t.text :sign_status, null: false
      t.boolean :appropriate, default: true
      t.boolean :display, default: true

      t.timestamps
    end
  end
end
