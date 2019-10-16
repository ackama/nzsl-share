class Folder < ApplicationRecord
  belongs_to :user
  validates :title,
            presence: true,
            uniqueness: { scope: :user_id, case_sensitive: false }

  def title=(new_title)
    super(new_title&.strip)
  end
end
