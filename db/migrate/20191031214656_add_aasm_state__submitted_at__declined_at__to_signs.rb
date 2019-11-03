class AddAasmStateSubmittedAtDeclinedAtToSigns < ActiveRecord::Migration[6.0]
  def change
    change_table :signs, bulk: true do |t|
      t.string :aasm_state, index: true
      t.datetime :submitted_at
      t.datetime :declined_at
    end

    Sign.update_all(aasm_state: "personal")

    change_column_null :signs, :aasm_state, false
  end
end
