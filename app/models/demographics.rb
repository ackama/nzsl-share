class Demographics
  class << self
    def config
      @config ||= OpenStruct.new(Rails.application.config_for(:demographics))
    end

    delegate :age_brackets, :ethnicities, :genders, :language_roles, to: :config
  end
end
