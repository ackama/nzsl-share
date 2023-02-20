require "rails_helper"

RSpec.describe DeleteUserJob, type: :job do
  let(:user) { FactoryBot.create(:user) }

  subject(:perform) { described_class.perform_now(user) }

  it "destroys the user" do
    expect { perform }.to change(user, :persisted?).to(false)
  end

  it "skips a user that has signs" do
    FactoryBot.create(:sign, contributor: user)
    allow(Rails.logger).to receive(:error)
    expect { perform }.not_to change(user, :persisted?)
    expect(Rails.logger).to have_received(:error).with(/Not deleting user/)
  end

  it "leaves comments in place, but nullifies the user" do
    comment = FactoryBot.create(:sign_comment, user:)
    expect { perform; comment.tap(&:reload) }.to change(comment, :user).from(user).to(nil)
    expect(comment).to be_persisted
  end

  it "destroys an uncollaborated folder" do
    FactoryBot.create(:folder, user:)
    expect { perform }.to change(Folder, :count).by(-1)
  end

  it "reallocates ownership of a folder with collaborators" do
    collaborators = FactoryBot.create_list(:user, 2)
    folder = FactoryBot.create(:folder, user:)
    folder.collaborators << collaborators
    expect { perform }.not_to change(Folder, :count)
    expect(folder.tap(&:reload).user).to eq collaborators.first
  end
end
