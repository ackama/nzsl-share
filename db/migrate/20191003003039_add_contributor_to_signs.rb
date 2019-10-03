class AddContributorToSigns < ActiveRecord::Migration[6.0]
  def up
    add_reference :signs,
                  :contributor, null: true,
                                foreign_key: { to_table: :users }
    Sign.where(contributor: nil)
        .update_all(contributor_id: User.first!.id)

    change_column_null :signs, :contributor_id, false
  end

  def down
    remove_column :signs, :contributor
  end
end
