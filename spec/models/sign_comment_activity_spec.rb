require "rails_helper"

RSpec.describe SignCommentActivity, type: :model do
  subject(:model) { FactoryBot.build(:sign_comment_activity) }

  it "belongs to a user" do
    expect(model.user).to be_a User
  end

  it "belongs to a sign comment" do
    expect(model.sign_comment).to be_a SignComment
  end
end
