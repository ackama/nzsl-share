class CommentReport < ApplicationRecord
  belongs_to :user
  belongs_to :comment, class_name: "SignComment"
  belongs_to :resolved_by, optional: true, class_name: "User"
end
