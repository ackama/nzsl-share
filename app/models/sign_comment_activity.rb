class SignCommentActivity < ApplicationRecord
  belongs_to :sign_comment
  belongs_to :user
  enum :key, { read: "read" }
end
