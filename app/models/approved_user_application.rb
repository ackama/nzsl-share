class ApprovedUserApplication < ApplicationRecord
  belongs_to :user
  validates :first_name, :last_name, presence: true

  validates :deaf, :nzsl_first_language, inclusion: { in: [true, false] }
  validates :age_bracket, inclusion: { in: ->(_record) { Demographics.age_brackets }, allow_blank: true }
  validates :gender, inclusion: { in: ->(_record) { Demographics.genders }, allow_blank: true }

  def language_roles=(new_roles)
    super(new_roles.reject(&:blank?))
  end
end
