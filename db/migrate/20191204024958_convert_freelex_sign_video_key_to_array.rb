class ConvertFreelexSignVideoKeyToArray < ActiveRecord::Migration[6.0]
  def up
    rename_column :freelex_signs, :video_key, :old_video_key
    add_column :freelex_signs, :video_key, :string, array: true, default: []
    FreelexSign.update_all("video_key=ARRAY[old_video_key]")
    remove_column :freelex_signs, :old_video_key
  end

  def down
    rename_column :freelex_signs, :video_key, :old_video_key
    add_column :freelex_signs, :video_key, :string
    FreelexSign.update_all("video_key=old_video_key[1]")
    remove_column :freelex_signs, :old_video_key
  end
end
