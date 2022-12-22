require "rails_helper"

RSpec.describe SignComment, type: :model do
  subject(:model) { FactoryBot.build(:sign_comment) }

  it { is_expected.to be_valid }

  context "without a folder" do
    before { model.folder = nil }
    it { is_expected.to be_valid }
  end

  context "with a folder" do
    subject(:model) { FactoryBot.build(:sign_comment, :with_folder) }
    it { is_expected.to be_valid }
    it { expect(model.folder).to be_a Folder }
  end

  describe ".read_by?" do
    let(:model) { FactoryBot.create(:sign_comment) }
    let(:user) { FactoryBot.create(:user) }

    subject { model.read_by?(user) }

    context "the user has read the comment" do
      before { model.read_by!(user) }
      it { is_expected.to eq true }
    end

    context "the user has not read the comment" do
      it { is_expected.to eq false }
    end
  end

  describe ".read_by!" do
    let(:model) { FactoryBot.create(:sign_comment) }
    let(:user) { FactoryBot.create(:user) }

    subject { model.read_by!(user) }

    it { expect { subject }.to change { SignCommentActivity.count }.by(1) }
    it { expect { subject }.to change { model.read_by?(user) }.from(false).to(true) }

    context "already read" do
      before { model.read_by!(user) }
      it { expect { subject }.not_to change(SignActivity, :count) }
    end
  end
end
