class ShareTokenIndex < ActiveRecord::Migration[6.0]
  def change
    add_index(:folders, :share_token)
  end
end
