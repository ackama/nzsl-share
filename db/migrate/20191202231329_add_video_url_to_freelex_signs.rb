class AddVideoUrlToFreelexSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :freelex_signs, :video_key, :string
  end
end
