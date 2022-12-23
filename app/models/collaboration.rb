class Collaboration < ApplicationRecord
  attr_accessor :identifier

  belongs_to :folder
  belongs_to :collaborator, class_name: :User, touch: true

  validates :collaborator_id, presence: {
    message: I18n.t("activerecord.errors.models.collaboration.collaborator.does_not_exist")
  }

  def self.for(collaborator, folder)
    find_by(collaborator: collaborator, folder: folder)
  end
end
