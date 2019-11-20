class SignActivity < ApplicationRecord
  ACTIVITY_AGREE = "agree".freeze
  ACTIVITY_DISAGREE = "disagree".freeze

  belongs_to :user
  belongs_to :sign
end
