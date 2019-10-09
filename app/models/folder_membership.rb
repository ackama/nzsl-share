class FolderMembership < ApplicationRecord
  belongs_to :folder, counter_cache: :signs_count
  belongs_to :sign
end
