class AddContributionLimitToUsers < ActiveRecord::Migration[6.0]
  def change
    default_contribution_limit = 50
    add_column :users,
               :contribution_limit,
               :integer,
               default: default_contribution_limit
  end
end
