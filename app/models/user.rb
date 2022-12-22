class User < ApplicationRecord
  include AASM

  USERNAME_REGEXP = /\A[a-zA-Z0-9_.]+\Z/
  PERMITTED_IMAGE_CONTENT_TYPE_REGEXP = %r{\Aimage/.+\Z}
  MAXIMUM_FILE_SIZE = 250.megabytes

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, authentication_keys: [:login]

  attr_writer :login

  has_many :folders, dependent: :destroy
  has_many :signs, foreign_key: :contributor_id, inverse_of: :contributor, dependent: :restrict_with_error
  has_many :collaborations, foreign_key: :collaborator_id, inverse_of: :collaborator, dependent: :destroy

  has_many :sign_comments, dependent: :nullify
  has_many :sign_comment_activities, dependent: :destroy

  has_one :approved_user_application, dependent: :destroy
  has_one_attached :avatar

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: USERNAME_REGEXP, multiline: true }

  validates :avatar, content_type: { with: PERMITTED_IMAGE_CONTENT_TYPE_REGEXP },
                     size: { less_than: MAXIMUM_FILE_SIZE }

  scope :confirmed, -> { where.not(id: unconfirmed) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

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
