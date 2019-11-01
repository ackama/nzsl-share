class AddAasmStateSubmittedAtDeclinedAtToSigns < ActiveRecord::Migration[6.0]
  def change
    change_table :signs, bulk: true do |t|
      t.string :aasm_state
      t.datetime :submitted_at
      t.datetime :declined_at
    end
  end
end
