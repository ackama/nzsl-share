class Folder < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  has_many :folder_memberships, dependent: :destroy
  has_many :signs, through: :folder_memberships
end
