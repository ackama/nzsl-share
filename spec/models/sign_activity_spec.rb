require "rails_helper"

RSpec.describe SignActivity, type: :model do
  subject(:model) { FactoryBot.build(:sign_activity) }

  it "belongs to a user" do
    expect(model.user).to be_a User
  end

  it "belongs to a sign" do
    expect(model.sign).to be_a Sign
  end
end
