require "rails_helper"

RSpec.describe CollaborationMailer, type: :mailer do
  include ActiveJob::TestHelper

  describe ".success" do
    let(:collaboration) { FactoryBot.create(:collaboration) }
    let(:user) { collaboration.collaborator }
    let(:mail) { CollaborationMailer.success(collaboration) }

    it "job is created" do
      ActiveJob::Base.queue_adapter = :test
      expect { mail.deliver_later }.to have_enqueued_job.on_queue("mailers")
    end

    it "success email is sent" do
      expect do
        perform_enqueued_jobs do
          CollaborationMailer.success(collaboration).deliver_later
        end
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it "success email is sent to the right user" do
      perform_enqueued_jobs do
        CollaborationMailer.success(collaboration).deliver_later
      end

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq user.email
    end

    it "renders the headers" do
      expect(mail.subject).to eq("NZSL Share - You are invited to join a team")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ApplicationMailer.default[:from]])
    end

    it "renders the body" do
      body = mail.body.encoded
      expect(body).to include("Someone has invited you to join a team on NZSL Share.")
      expect(body).to include folder_url(collaboration.folder)
    end
  end
end
