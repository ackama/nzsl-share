class Folder < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :folder_memberships, dependent: :destroy
  has_many :signs, through: :folder_memberships
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, class_name: "User", through: :collaborations

  scope :in_order, -> { order(title: :asc) }

  validates :title,
            presence: true,
            uniqueness: { scope: :user_id, case_sensitive: false }

  def title=(new_title)
    super(new_title&.strip)
  end

  def self.make_default(title = nil)
    new(title: title.presence || I18n.t("folders.default_title"))
  end
end
