class AddRequestedDeletionAtToSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :signs, :requested_deletion_at, :datetime
  end
end
