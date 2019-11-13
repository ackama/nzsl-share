class AddConfirmableToUsers < ActiveRecord::Migration[6.0]
  def up
    change_table :users, bulk: true do |t|
      t.string :confirmation_token, unique: true
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end

    User.update_all confirmed_at: DateTime.now
  end

  def down
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :users, :unconfirmed_email # Only if using reconfirmable
  end
end
