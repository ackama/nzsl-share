class Demographic < ApplicationRecord
  belongs_to :user
  validates :first_name, :last_name, presence: true

  validates :deaf, :nzsl_first_language, inclusion: { in: [true, false] }
  validates :age_bracket, inclusion: { in: ->(_record) { Demographic.age_brackets }, allow_blank: true }
  validates :gender, inclusion: { in: ->(_record) { Demographic.genders }, allow_blank: true }

  def language_roles=(new_roles)
    super(new_roles.reject(&:blank?))
  end

  class << self
    def config
      @config ||= OpenStruct.new(Rails.application.config_for(:demographics))
    end

    delegate :age_brackets, :ethnicities, :genders, :language_roles, to: :config
  end
end
