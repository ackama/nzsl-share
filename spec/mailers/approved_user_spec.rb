require "rails_helper"

RSpec.describe ApprovedUserMailer, type: :mailer do
  describe ".submitted" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.submitted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("NZSL Share - Thank you for your application")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to include("We have received your application.")
    end
  end

  describe ".accepted" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.accepted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("NZSL Share - You have been accepted as an approved member")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to include("Congratulations, you are now an Approved Member of NZSL Share!")
    end
  end

  describe ".declined" do
    let(:application) { FactoryBot.build(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.declined(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("NZSL Share - Sorry, your application has not been approved")
      expect(mail.to).to eq([application.user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to include("We have not accepted your application")
    end
  end

  describe ".admin_submitted" do
    let!(:admin) { FactoryBot.create(:user, :administrator) }
    let(:application) { FactoryBot.create(:approved_user_application) }
    let(:mail) { ApprovedUserMailer.admin_submitted(application) }

    it "renders the headers" do
      expect(mail.subject).to eq("NZSL Share Admin - Member application")
      expect(mail.to).to eq([admin.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expected = "A new approved member application has been received for #{application.user.username}."
      expect(body).to include(expected)
    end
  end
end
