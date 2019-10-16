class Folder < ApplicationRecord
  belongs_to :user
  has_many :folder_memberships, dependent: :destroy
  has_many :signs, through: :folder_memberships
  scope :in_order, -> { order(title: :asc) }

  validates :title,
            presence: true,
            uniqueness: { scope: :user_id, case_sensitive: false }

  def title=(new_title)
    super(new_title&.strip)
  end
end
