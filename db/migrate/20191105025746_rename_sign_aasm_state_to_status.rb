class RenameSignAasmStateToStatus < ActiveRecord::Migration[6.0]
  def change
    rename_column :signs, :aasm_state, :status
  end
end
