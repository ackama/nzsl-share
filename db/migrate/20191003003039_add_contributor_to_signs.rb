class AddContributorToSigns < ActiveRecord::Migration[6.0]
  class User < ApplicationRecord; end

  def up
    add_reference :signs,
                  :contributor, null: true,
                                foreign_key: { to_table: :users }

    user = User.where(username: "unknowncontributor")
               .first_or_initialize
               .tap { |u| u.save(validate: false) }
    Sign.where(contributor: nil).update_all(contributor_id: user.id)

    change_column_null :signs, :contributor_id, false
  end

  def down
    remove_column :signs, :contributor
  end
end
