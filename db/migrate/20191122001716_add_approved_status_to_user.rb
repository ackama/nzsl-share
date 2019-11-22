class AddApprovedStatusToUser < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :approval_status, :string, default: :unapproved, index: true
    User.where(approved: true).update_all(approval_status: :approved)
    remove_column :users, :approved
  end

  def down
    add_column :users, :approved, :boolean, default: false, index: true
    User.where(approval_status: :approved).update_all(approved: true)
    remove_column :users, :approval_status
  end
end
