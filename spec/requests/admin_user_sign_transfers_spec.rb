require "rails_helper"

RSpec.describe "/admin/user_sign_transfers", type: :request do
  let(:user) { FactoryBot.create(:user, :administrator) }
  let(:old_owner) { FactoryBot.create(:user) }
  let(:new_owner) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET /admin/user_sign_transfers/new" do
    it "loads the page if an old owner is provided" do
      get new_admin_user_sign_transfer_path(old_owner: old_owner)
      expect(response).to have_http_status(:ok)
    end

    it "redirects if an old owner is not supplied" do
      get new_admin_user_sign_transfer_path
      expect(response).to redirect_to root_path
      follow_redirect!
      expect(response.body).to include(I18n.t("admin.user_sign_transfers.new.old_owner_required"))
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        expect do
          get new_admin_user_sign_transfer_path(old_owner: old_owner)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "POST /admin/user_sign_transfers" do
    it "updates the owner of the signs" do
      signs = FactoryBot.create_list(:sign, 3, :published, contributor: old_owner)
      post admin_user_sign_transfers_path(old_owner: old_owner, new_owner: new_owner)
      signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(new_owner)
      end
    end

    it "updates folders correctly" do
      folder = FactoryBot.create(:folder)
      published_signs = FactoryBot.create_list(:sign, 2, :published, contributor: old_owner, folders: [folder])
      unpublished_signs = FactoryBot.create_list(:sign, 2, contributor: old_owner, folders: [folder])
      post admin_user_sign_transfers_path(old_owner: old_owner, new_owner: new_owner)

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
      post admin_user_sign_transfers_path(old_owner: old_owner, new_owner: new_owner)

      old_owner_signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(new_owner)
      end

      unrelated_signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(unrelated_user)
      end
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        expect do
          post admin_user_sign_transfers_path(old_owner: old_owner, new_owner: new_owner)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
