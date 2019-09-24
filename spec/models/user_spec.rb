require "rails_helper"

RSpec.describe User, type: :model do
  subject(:model) { FactoryBot.build(:user) }

  it { is_expected.to be_valid }

  context "without a username" do
    subject { FactoryBot.build(:user, username: "") }
    it { is_expected.not_to be_valid }
  end

  context "with a duplicate username" do
    subject { model.tap(&:save!).dup }
    it { is_expected.not_to be_valid }
  end
end
