class RemoveAppropriateFlagFromSignComments < ActiveRecord::Migration[6.0]
  def change
    remove_column :sign_comments, :appropriate, :boolean, null: false, default: false
  end
end
