class EditSignForm
  include ActiveModel::Model
  attr_writer :should_submit_for_publishing

  delegate_missing_to :sign

  def initialize(sign, params={})
    @sign = sign
    super(params)
  end

  def self.from_model(sign)
    @sign = sign
  end

  def should_submit_for_publishing
    @should_submit_for_publishing || sign_submitted_to_publish
  end

  def save
    @sign.tap do |sign|
      if should_submit_for_publishing
        sign.save
        sign.submit_for_publishing!
      end
    end
  end

  private

  def sign
    @sign ||= Sign.new
  end

  def sign_submitted_to_publish
    sign.submitted? || sign.published? || sign.declined?
  end
end
