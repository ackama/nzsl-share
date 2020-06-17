class SignTopic < ApplicationRecord
  belongs_to :topic
  belongs_to :sign, touch: true
end
