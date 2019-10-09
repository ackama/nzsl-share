class FolderMembership < ApplicationRecord
  belongs_to :folder
  belongs_to :sign

  def self.for(sign, user=nil)
    FolderMembership
      .where(sign: sign)
      .yield_self { |sp| user.nil? ? sp : sp.includes(:folder).where(folders: { user_id: user.id }) }
  end
end
