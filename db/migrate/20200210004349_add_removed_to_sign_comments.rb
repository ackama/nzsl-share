class AddRemovedToSignComments < ActiveRecord::Migration[6.0]
  def change
    add_column :sign_comments, :removed, :boolean, default: false
  end
end
