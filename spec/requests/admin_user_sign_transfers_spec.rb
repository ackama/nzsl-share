require "rails_helper"

RSpec.describe "/admin/user_sign_transfers", type: :request do
  let(:user) { FactoryBot.create(:user, :administrator) }
  let(:old_owner) { FactoryBot.create(:user) }
  let(:new_owner) { FactoryBot.create(:user) }

  before { sign_in user }

  describe "GET /admin/user_sign_transfers/new" do
    it "loads the page if an old owner is provided" do
      get new_admin_user_sign_transfer_path(old_owner:)
      expect(response).to have_http_status(:ok)
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        get new_admin_user_sign_transfer_path(old_owner:)

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include "NotAuthorizedError"
      end
    end
  end

  describe "POST /admin/user_sign_transfers" do
    it "updates the owner of the signs" do
      signs = FactoryBot.create_list(:sign, 3, :published, contributor: old_owner)
      post admin_user_sign_transfers_path(old_owner:, new_owner:)
      signs.each do |sign|
        sign.reload
        expect(sign.contributor).to eq(new_owner)
      end
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        post admin_user_sign_transfers_path(old_owner:, new_owner:)

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include "NotAuthorizedError"
      end
    end
  end
end
