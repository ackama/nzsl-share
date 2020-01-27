class Collaboration < ApplicationRecord
  attr_accessor :identifier
  belongs_to :folder
  belongs_to :collaborator, class_name: :User

  validates :folder_id, presence: true
  validates :collaborator_id, presence: { message: "This username does not exist" }
end
