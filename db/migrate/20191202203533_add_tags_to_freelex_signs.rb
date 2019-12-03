class AddTagsToFreelexSigns < ActiveRecord::Migration[6.0]
  def change
    add_column :freelex_signs, :tags, :string, array: true, default: []
  end
end
