class Demographics
  class << self
    def config
      @config ||= Rails.application.config_for(:demographics)
    end

    %i[age_brackets ethnicities genders language_roles].each do |demographic_type|
      define_method(demographic_type) { config[demographic_type] }
    end
  end
end
