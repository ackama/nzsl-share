class Collaboration < ApplicationRecord
  belongs_to :folder
  belongs_to :collaborator, class_name: :User
end
