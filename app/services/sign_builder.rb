class SignBuilder
  attr_reader :sign
  delegate :valid?, to: :sign

  def build(sign_params)
    @sign = Sign.new(sign_params).tap do |sign|
      sign.word.presence || (sign.word = derive_word_from_attachment(sign.video))
    end

    self
  end

  def save!
    @sign.save!
    enqueue_jobs

    true
  end

  def save
    save!
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def enqueue_jobs
    SignPublishVideoJob.perform_later @sign
  end

  def derive_word_from_attachment(attachment)
    return I18n.t("signs.default_placeholder_word") if attachment.blank?

    # Return the filename without extension
    File.basename(attachment.filename.to_s).split(".").first
  end
end
