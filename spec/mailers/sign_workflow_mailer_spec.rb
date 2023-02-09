require "rails_helper"

RSpec.describe SignWorkflowMailer, type: :mailer do
  describe ".moderation_requested" do
    let(:sign) { FactoryBot.build_stubbed(:sign, :submitted) }
    let(:moderators) { ["moderator@example.com"] }

    subject(:mail) do
      mailer = described_class.new
      allow(mailer).to receive(:moderators).and_return moderators
      mailer.process(:moderation_requested, sign)

      mailer.message
    end

    it "sends mail to all moderators" do
      expect(mail.bcc).to eq moderators
    end

    it "has the expected subject" do
      expect(mail.subject).to eq I18n.t!("sign_workflow_mailer.moderation_requested.subject")
    end

    it "has the expected body text" do
      expect(mail.body.decoded).to include "#{sign.contributor.username} has submitted the sign #{sign.word}"
    end
  end

  describe ".published" do
    let(:sign) { FactoryBot.build_stubbed(:sign, :published) }

    subject(:mail) do
      mailer = described_class.new
      mailer.process(:published, sign)

      mailer.message
    end

    it "sends mail to the sign's contributor" do
      expect(mail.to).to eq [sign.contributor.email]
    end

    it "has the expected subject" do
      expect(mail.subject).to eq I18n.t!("sign_workflow_mailer.published.subject")
    end

    it "has the expected body text" do
      expect(mail.body.decoded).to include "Your sign ‘#{sign.word}’ has been approved"
    end
  end

  describe ".declined" do
    let(:sign) { FactoryBot.build_stubbed(:sign, :declined) }

    subject(:mail) do
      mailer = described_class.new
      mailer.process(:declined, sign)

      mailer.message
    end

    it "sends mail to the sign's contributor" do
      expect(mail.to).to eq [sign.contributor.email]
    end

    it "has the expected subject" do
      expect(mail.subject).to eq I18n.t!("sign_workflow_mailer.declined.subject")
    end

    it "has the expected body text" do
      expect(mail.body.decoded).to include "Your sign ‘#{sign.word}’ has been declined"
    end
  end
end
