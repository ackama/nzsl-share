require "rails_helper"

RSpec.describe "Sidekiq authentication", type: :request do
  describe "GET /sidekiq" do
    subject { get "/sidekiq"; response }
    context "signed in as an administrator" do
      before { sign_in FactoryBot.create(:user, :administrator) }
      it { is_expected.to be_ok }
    end

    context "signed in, not as an administrator" do
      before { sign_in FactoryBot.create(:user) }

      it "returns an http not found error" do
        subject

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include "Routing Error"
      end
    end

    context "not signed in" do
      it { is_expected.to redirect_to "/users/sign_in" }
    end
  end
end
