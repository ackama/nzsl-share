class User < ApplicationRecord
  USERNAME_REGEXP = /\A[a-zA-Z0-9_\.]*\Z/.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:login]

  attr_writer :login
  has_many :folders, dependent: :destroy
  has_many :signs, foreign_key: :contributor_id, inverse_of: :contributor, dependent: :nullify

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: USERNAME_REGEXP, multiline: true }

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    unless (login = conditions.delete(:login))
      fail ArgumentError, "Expected Warden conditions to include :login and it did not: #{warden_conditions}"
    end

    where(conditions.to_h).find_by("lower(username) = :value OR lower(email) = :value", value: login)
  end
end
