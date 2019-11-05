class AddRequestedUnpublishAtToSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :signs, :requested_unpublish_at, :datetime
  end
end
