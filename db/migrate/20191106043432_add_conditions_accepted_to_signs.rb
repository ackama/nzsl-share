class AddConditionsAcceptedToSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :signs, :conditions_accepted, :boolean, default: false
  end
end
