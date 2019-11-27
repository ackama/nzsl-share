class ApprovedUserApplication < ApplicationRecord
  include AASM

  belongs_to :user
  validates :first_name, :last_name, presence: true

  validates :deaf, :nzsl_first_language, inclusion: { in: [true, false] }
  validates :age_bracket, inclusion: { in: ->(_record) { Demographics.age_brackets }, allow_blank: true }
  validates :gender, inclusion: { in: ->(_record) { Demographics.genders }, allow_blank: true }

  aasm column: :status do
    state :submitted, initial: true
    state :accepted
    state :declined

    event :accept, after: :after_accepted do
      transitions from: :submitted, to: :accepted
    end

    event :decline, after: -> { ApprovedUserMailer.declined(self).deliver_later } do
      transitions from: :submitted, to: :declined
    end
  end

  def after_accepted
    user.update!(approved: true)
    ApprovedUserMailer.accepted(self).deliver_later
  end

  def language_roles=(new_roles)
    super(new_roles.reject(&:blank?))
  end
end
