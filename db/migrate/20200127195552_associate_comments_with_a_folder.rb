class AssociateCommentsWithAFolder < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :sign_comments, :folder, null: true
  end
end
