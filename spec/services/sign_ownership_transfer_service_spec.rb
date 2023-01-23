require "rails_helper"

RSpec.describe SignBuilder, type: :service do
  describe ".transfer_sign" do
    subject { SignOwnershipTransferService.new }

    let(:user) { FactoryBot.create(:user, :administrator) }
    let(:old_owner) { FactoryBot.create(:user) }
    let(:new_owner) { FactoryBot.create(:user) }

    it "updates the owner of the signs" do
      signs = FactoryBot.create_list(:sign, 3, :published, contributor: old_owner)
      subject.transfer_sign(old_owner: old_owner, new_owner: new_owner)
      signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(new_owner)
      end
    end

    it "updates folders correctly" do
      folder = FactoryBot.create(:folder)
      published_signs = FactoryBot.create_list(:sign, 2, :published, contributor: old_owner, folders: [folder])
      unpublished_signs = FactoryBot.create_list(:sign, 2, contributor: old_owner, folders: [folder])
      subject.transfer_sign(old_owner: old_owner, new_owner: new_owner)

      published_signs.each do |sign|
        sign.reload
        expect(sign.folders).to eq([folder])
      end

      unpublished_signs.each do |sign|
        sign.reload
        expect(sign.folders).to eq([])
      end
    end

    it "doesn't update the signs of other users" do
      unrelated_user = FactoryBot.create(:user)
      old_owner_signs = FactoryBot.create_list(:sign, 3, :published, contributor: old_owner)
      unrelated_signs = FactoryBot.create_list(:sign, 3, :published, contributor: unrelated_user)
      subject.transfer_sign(old_owner: old_owner, new_owner: new_owner)

      old_owner_signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(new_owner)
      end

      unrelated_signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(unrelated_user)
      end
    end

    it "will not transfer signs to the system user" do
      signs = FactoryBot.create_list(:sign, 3, :published, contributor: old_owner)
      new_owner = SystemUser.find
      subject.transfer_sign(old_owner: old_owner, new_owner: new_owner)
      signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(old_owner)
      end
    end
  end
end
