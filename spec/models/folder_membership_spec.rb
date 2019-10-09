require "rails_helper"

RSpec.describe FolderMembership, type: :model do
  subject { FactoryBot.build(:folder_membership) }
  it { is_expected.to be_valid }

  describe ".for" do
    let(:owner) { FactoryBot.create(:user) }
    let(:sign) { FactoryBot.create(:sign) }
    let(:folder) { FactoryBot.create(:folder, user: owner) }
    let!(:owned_for_sign) { FactoryBot.create(:folder_membership, folder: folder, sign: sign) }
    let!(:not_owned_for_sign) { FactoryBot.create(:folder_membership, sign: sign) }
    let!(:not_owned_not_for_sign) { FactoryBot.create(:folder_membership) }

    it "is expected to return memberships for the owner and sign" do
      expect(FolderMembership.for(sign, owner)).to eq [owned_for_sign]
    end

    it "is expected to return memberships for the sign when no owner is provided" do
      expect(FolderMembership.for(sign)).to eq [owned_for_sign, not_owned_for_sign]
    end

    it "is expected not to return results for another sign" do
      expect(FolderMembership.for(FactoryBot.create(:sign))).to eq []
    end

    it "is expected not to return results for another user" do
      expect(FolderMembership.for(sign, FactoryBot.create(:user))).to eq []
    end
  end
end
