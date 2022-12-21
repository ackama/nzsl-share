require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  it "inherits from ApplicationPolicy" do
    expect(described_class.superclass).to eq ApplicationPolicy
  end

  permissions :index?, :edit?, :update?, :destroy? do
    let(:record) { User.new }

    it "allows an administrator" do
      user = User.new(administrator: true)
      expect(subject).to permit(user, record)
    end

    it "does not allow a moderator" do
      user = User.new(moderator: true)
      expect(subject).not_to permit(user, record)
    end

    it "does not allow a validator" do
      user = User.new(validator: true)
      expect(subject).not_to permit(user, record)
    end

    it "does not allow a approved user" do
      user = User.new(approved: true)
      expect(subject).not_to permit(user, record)
    end

    it "does not a allow a user" do
      user = User.new
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :destroy? do
    it "does not allow destroying a user who has contributed signs" do
      sign = FactoryBot.create(:sign)
      user = User.new(administrator: true)
      expect(subject).not_to permit(user, sign.contributor)
    end
  end
end
