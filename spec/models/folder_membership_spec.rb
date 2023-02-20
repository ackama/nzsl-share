require "rails_helper"

RSpec.describe FolderMembership, type: :model do
  subject { FactoryBot.build(:folder_membership) }
  it { is_expected.to be_valid }

  describe ".owner_of" do
    let(:sign) { FactoryBot.create(:sign) }

    subject { FolderMembership.owner_of(sign) }

    context "user is owner of the sign in this folder" do
      let(:folder) { FactoryBot.create(:folder, user:) }
      let(:expected) { FactoryBot.create(:folder_membership, folder:, sign:) }
      let(:user) { sign.contributor }
      it { is_expected.to match_array(expected) }
    end

    context "user is not owner of the sign in this folder" do
      let(:folder) { FactoryBot.create(:folder, user:) }
      let(:expected) { FactoryBot.create(:folder_membership, folder:, sign:) }
      let(:user) { FactoryBot.create(:user) }
      it { is_expected.to be_empty }
    end
  end
end
