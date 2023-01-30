class SignUpdater
  def initialize(sign, sign_params)
    @sign = sign
    @sign_params = sign_params
  end

  def update
    return unless @sign.update(@sign_params)

    SignPostProcessor.new(@sign).process if @sign_params.key?(:video)

    @sign
  end
end
