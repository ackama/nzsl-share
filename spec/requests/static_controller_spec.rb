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
      it { expect { subject }.to raise_error ActionController::RoutingError, "Unknown page: madeup" }
    end
  end
end
