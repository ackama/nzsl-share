class SignBatchOperationsController < ApplicationController
  BULK_OPERATIONS_LIMIT = 100

  before_action :authenticate_user!

  def create
    operation = resolve_operation
    return head(:unprocessable_entity) unless operation

    precondition = method(:authorize_operation)
    batch = BatchOperation.new(signs, operation, &precondition)
    succeeded, failed = batch.process

    respond_to do |format|
      format.json { render json: { succeeded: succeeded, failed: failed } }
      format.html do
        redirect_to signs_path, notice: t(".success",
                                          succeeded_count: succeeded.size,
                                          failed_count: failed.size)
      end
    end
  end

  private

  def resolve_operation
    case operation_name&.to_sym
    when :assign_topic
      method(:assign_topic)
    end
  end

  def authorize_operation(record)
    permission = operation_name == :submit_for_publishing ? :submit? : :update?
    policy(record).public_send(permission)
  end

  def assign_topic(record)
    record.topics << policy_scope(Topic).find(params.require(:topic_id))
  end

  def operation_name
    params.require(:operation)
  end

  def signs
    policy_scope(Sign.where(id: params.require(:sign_ids)).limit(BULK_OPERATIONS_LIMIT))
  end
end
