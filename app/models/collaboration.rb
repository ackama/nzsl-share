class Collaboration < ApplicationRecord
  belongs_to :folder
  belongs_to :collaborator, class_name: :User

  validates :folder, presence: true
  validates :collaborator, presence: true
end
