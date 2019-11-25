require "rails_helper"

RSpec.describe ApprovedUserMailer, type: :mailer do
  describe ".submitted" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.submitted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("We've received your application")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to match("Hi #{application.user.username}")
      expect(body).to include("We have received your application to become an")
    end
  end

  describe ".accepted" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.accepted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("We've accepted your application")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to match("Hi #{application.user.username}")
      expect(body).to include("We have accepted your application to become an")
    end
  end

  describe ".declined" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.declined(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your application to become an approved user needs some changes")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to match("Hi #{application.user.username}")
      expect(body).to include("We need you to make some changes to your application")
    end
  end

  describe ".admin_submitted" do
    let!(:admin) { FactoryBot.create(:user, :administrator) }
    let(:application) { FactoryBot.create(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.admin_submitted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("New approved user application received")
      expect(mail.to).to eq([admin.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expected = "A new approved user application has been received for #{application.user.username}."
      expect(body).to include(expected)
    end
  end
end
