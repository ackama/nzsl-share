require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe ".admins" do
    subject { described_class.new.admins }

    it "includes an admin user" do
      user = FactoryBot.create(:user, :administrator)
      expect(subject).to include user.email
    end

    it "excludes a regular user" do
      user = FactoryBot.create(:user)
      expect(subject).not_to include user.email
    end

    it "excludes a moderator" do
      user = FactoryBot.create(:user, :moderator)
      expect(subject).not_to include user.email
    end
  end

  describe ".moderators" do
    subject { described_class.new.moderators }

    it "excludes an admin user" do
      user = FactoryBot.create(:user, :administrator)
      expect(subject).not_to include user.email
    end

    it "excludes a regular user" do
      user = FactoryBot.create(:user)
      expect(subject).not_to include user.email
    end

    it "includes a moderator" do
      user = FactoryBot.create(:user, :moderator)
      expect(subject).to include user.email
    end
  end
end
