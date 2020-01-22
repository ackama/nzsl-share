class Collaboration < ApplicationRecord
  attr_accessor :identifier
  belongs_to :folder
  belongs_to :collaborator, class_name: :User

  validates :folder_id, presence: true
  validates :collaborator_id, presence: true
  # validates :identifier, presence: true
end
