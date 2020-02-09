class CommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :comment, class_name: "SignComment"
end
