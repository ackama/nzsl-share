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
      format.json { render json: { succeeded:, failed: } }
      format.html do
        redirect_to user_signs_path(sign_ids:),
                    **flash_messages_for_result(succeeded, failed)
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
    when :echo
      method(:echo)
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

  ##
  # Just used for testing, just succeed the record
  def echo(record)
    record
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
    params.fetch(:sign_ids, [])
  end

  def signs
    policy_scope(Sign.where(id: sign_ids)).limit(BULK_OPERATIONS_LIMIT)
  end

  def flash_messages_for_result(succeeded_records, failed_records)
    if !succeeded_records.empty? && failed_records.empty?
      { notice: t(".success", succeeded_count: succeeded_records.size) }
    elsif !succeeded_records.empty? || !failed_records.empty?
      { alert: t(".mixed_success", succeeded_count: succeeded_records.size, failed_count: failed_records.size) }
    else
      { alert: t(".failure_missing_sign_ids") }
    end
  end
end
