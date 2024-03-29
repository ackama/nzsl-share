# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  after_action :create_default_folder, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter

  private

  def create_default_folder
    return unless resource.persisted?

    resource.folders << Folder.make_default
  end
end
