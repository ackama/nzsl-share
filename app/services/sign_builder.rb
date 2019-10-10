class SignBuilder
  def build(sign_params)
    Sign.new(sign_params).tap do |sign|
      sign.english.presence || (sign.english = derive_word_from_attachment(sign.video))
    end
  end

  private

  def derive_word_from_attachment(attachment)
    return I18n.t("signs.default_placeholder_word") if attachment.blank?

    # Return the filename without extension
    File.basename(attachment.filename.to_s).split(".").first
  end
end
