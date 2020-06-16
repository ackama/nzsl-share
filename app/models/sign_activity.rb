class SignActivity < ApplicationRecord
  ACTIVITY_AGREE = "agree".freeze
  ACTIVITY_DISAGREE = "disagree".freeze

  belongs_to :user, touch: true
  belongs_to :sign, touch: true

  class << self
    def for_type(type, attrs={})
      where(attrs.merge(key: type)).first_or_initialize
    end

    def agree!(attrs)
      for_type(ACTIVITY_DISAGREE, attrs)&.destroy
      agreement(attrs).tap(&:save!)
    end

    def disagree!(attrs)
      for_type(ACTIVITY_AGREE, attrs)&.destroy
      disagreement(attrs).tap(&:save!)
    end

    def agreement(attrs)
      for_type(SignActivity::ACTIVITY_AGREE, attrs)
    end

    def disagreement(attrs)
      for_type(SignActivity::ACTIVITY_DISAGREE, attrs)
    end

    def agree?(attrs)
      agreement(attrs).persisted?
    end

    def disagree?(attrs)
      disagreement(attrs).persisted?
    end
  end
end
