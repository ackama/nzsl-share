class AddBatchSignContributionsPermittedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :batch_sign_contributions_permitted, :boolean, default: false, null: false
  end
end
