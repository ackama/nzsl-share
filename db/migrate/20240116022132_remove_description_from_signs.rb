class RemoveDescriptionFromSigns < ActiveRecord::Migration[7.0]
  def change
    remove_column :signs, :description, :text
  end
end
