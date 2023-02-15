class SignBatchOperationsController < ApplicationController
  BULK_OPERATIONS_LIMIT = 100

  before_action :authenticate_user!

  def create
    operation = resolve_operation
    authorize_operation = method(:authorize_record_operation)
    batch = BatchOperation.new(signs, operation, precondition: authorize_operation)
    return if performed? # Stop processing if any of the prepartion methods have halted the request

    succeeded, failed = batch.process

    respond_to do |format|
      format.json { render json: { succeeded: succeeded, failed: failed } }
      format.html do
        redirect_to user_signs_path(sign_ids: sign_ids),
                    notice: t(".success", succeeded_count: succeeded.size,
                                          failed_count: failed.size)
      end
    end
  end

  private

  def resolve_operation
    case operation_name&.to_sym
    when :assign_topic
      method(:assign_topic)
    when :submit_for_publishing
      method(:submit_for_publishing)
    else
      head(:unprocessable_entity)
    end
  end

  def authorize_record_operation(record)
    permission = operation_name == :submit_for_publishing ? :submit? : :update?
    policy(record).public_send(permission)
  end

  def assign_topic(record)
    record.topics << policy_scope(Topic).find(params.require(:topic_id))
  end

  def submit_for_publishing(record)
    record.conditions_accepted = true
    record.submit

    record.save
  end

  def operation_name
    params.require(:operation).to_sym
  end

  def sign_ids
    params.require(:sign_ids)
  rescue ActionController::ParameterMissing
    redirect_to(user_signs_path, alert: t(".failure_missing_sign_ids"))
  end

  def signs
    policy_scope(Sign.where(id: sign_ids)).limit(BULK_OPERATIONS_LIMIT)
  end
end
