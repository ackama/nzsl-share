class Collaboration < ApplicationRecord
  belongs_to :folder, counter_cache: :signs_count
  belongs_to :collaborator, class_name: :User
end
