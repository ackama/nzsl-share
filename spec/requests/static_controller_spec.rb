require "rails_helper"

RSpec.describe StaticController, type: :request do
  describe "GET show" do
    subject { get page_path(page); response }

    context "known page" do
      let(:page) { :about }
      it { is_expected.to be_ok }
    end

    context "unknown page" do
      let(:page) { :madeup }

      it "returns an http not found error" do
        subject

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include "Unknown page: madeup"
      end
    end
  end
end
