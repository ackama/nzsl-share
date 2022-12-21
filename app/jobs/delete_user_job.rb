class DeleteUserJob < ApplicationJob
  def perform(user)
    return Rails.logger.error "Not deleting user #{user.to_gid} with signs" if user.signs.any?

    User.transaction do
      reallocate_shared_folders(user)
      user.reload # Make sure that we don't destroy folders that have been reallocated

      user.destroy
    end
  end

  private

  def reallocate_shared_folders(user)
    user.folders.each do |folder|
      next_collaborator = folder.collaborators.where.not(id: user).first
      next unless next_collaborator

      folder.update!(user: next_collaborator)
    end
  end
end
