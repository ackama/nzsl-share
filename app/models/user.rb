class User < ApplicationRecord
  include AASM

  USERNAME_REGEXP = /\A[a-zA-Z0-9_\.]*\Z/.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, authentication_keys: [:login]

  attr_writer :login
  has_many :folders, dependent: :destroy
  has_many :signs, foreign_key: :contributor_id, inverse_of: :contributor, dependent: :nullify
  has_one :approved_user_application, dependent: :destroy

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: USERNAME_REGEXP, multiline: true }

  aasm column: :approval_status do
    state :unapproved, initial: true
    state :pending_approval
    state :approved
    state :approval_declined

    event :submit_application, after: -> { ApprovedUserMailer.pending(self).deliver_later } do
      transitions from: %i[unapproved approval_declined],
                  to: :pending_approval,
                  guard: -> { demographic&.valid? }
    end

    event :approve_application, after: -> { ApprovedUserMailer.approved(self).deliver_later } do
      transitions from: :pending_approval, to: :approved
    end

    event :decline_application, after: -> { ApprovedUserMailer.declined(self).deliver_later } do
      transitions from: :pending_approval, to: :approval_declined
    end
  end

  def username=(value)
    super(value.downcase)
  end

  def login
    @login || username || email
  end

  def contribution_limit_reached?
    signs.count >= contribution_limit
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    unless (login = conditions.delete(:login))
      fail ArgumentError, "Expected Warden conditions to include :login and it did not: #{warden_conditions}"
    end

    where(conditions.to_h).find_by("lower(username) = :value OR lower(email) = :value", value: login.downcase)
  end
end
