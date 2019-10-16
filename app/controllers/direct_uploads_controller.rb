class DirectUploadsController < ActiveStorage::DirectUploadsController
  # We are overriding a controller, so this action _does_ exist.
  before_action :validate_blob_args, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter

  def validate_blob_args
    DirectUploadValidator.new.validate!(blob_args)
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
    false
  end
end
