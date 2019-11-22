require "rails_helper"

RSpec.describe ApprovedUserMailer, type: :mailer do
  describe ".submitted" do
    let(:user) { FactoryBot.build(:user) }
    let(:mail) { ApprovedUserMailer.submitted(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("We've received your application")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to match("Hi #{user.username}")
      expect(body).to include("We have received your application to become an")
    end
  end
end
