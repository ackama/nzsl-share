require "rails_helper"

RSpec.describe SystemUser, type: :model do
  describe ".find" do
    subject { SystemUser.find }

    context "doesn't exist" do
      it { expect { subject }.to change(User, :count) }
      it { expect(subject).to be_a User }
    end

    context "already exists" do
      before { subject }
      it { expect { subject }.not_to change(User, :count) }
      it { expect(subject).to be_a User }
    end
  end
end
