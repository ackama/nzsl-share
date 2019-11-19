class FolderMembership < ApplicationRecord
  belongs_to :folder, counter_cache: :signs_count
  belongs_to :sign

  scope :owner_of, lambda { |sign|
    joins(:folder).where(sign_id: sign.id, folders: { user_id: sign.contributor_id })
  }
end
