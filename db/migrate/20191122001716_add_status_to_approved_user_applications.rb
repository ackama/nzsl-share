class AddStatusToApprovedUserApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :approved_user_applications, :status, :string, default: :submitted
    add_index :approved_user_applications, :status
  end
end
