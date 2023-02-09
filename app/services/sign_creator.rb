class SignCreator
  attr_reader :sign

  def initialize(sign_params)
    @sign_params = sign_params
    @sign = Sign.new(sign_params).tap do |sign|
      sign.word.presence || (sign.word = derive_word_from_attachment(sign.video))
    end
  end

  def create
    return unless @sign.save

    SignPostProcessor.new(@sign).process

    @sign
  end

  def derive_word_from_attachment(attachment)
    return I18n.t("signs.default_placeholder_word") if attachment.blank?

    # Return the filename without extension
    File.basename(attachment.filename.to_s).split(".").first
  end
end
