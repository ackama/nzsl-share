require "rails_helper"

RSpec.describe TopicPolicy do
  let(:user) { User.new }
  let(:topic) { Topic.new }

  subject(:policy) { described_class.new(user, topic) }

  it "inherits from ApplicationPolicy" do
    expect(described_class.superclass).to eq ApplicationPolicy
  end

  describe ".scope" do
    subject { policy.scope }

    it "returns an undecorated scope" do
      expect(subject).to eq Topic
    end
  end
end
