class SignOwnershipTransferService
  def transfer_sign(old_owner:, new_owner:)
    return unless old_owner && new_owner

    old_owner.signs.each do |sign|
      if sign.published?
        sign.update(contributor: new_owner)
      else
        sign.update(contributor: new_owner, folders: [])
      end
    end
  end
end
