class AddNotesToSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :signs, :notes, :text
    add_index(:signs, :notes)
  end
end
