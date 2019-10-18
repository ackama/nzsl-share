require "rails_helper"

RSpec.describe SignVideoController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:fake_representation_url) { "https://example.com/fake-representation" }
  let(:fake_representation) { double(exist?: true, processed: fake_representation_url) }

  describe "GET #show" do
    let!(:sign_id) { FactoryBot.create(:sign).id }
    let(:preset) { "1080p" }
    before { allow(CachedVideoTranscoder).to receive(:new).and_return(fake_representation) }
    subject { get :show, params: { sign_id: sign_id, preset: preset } }

    context "valid params" do
      context "preset representation does not exist" do
        before { allow(fake_representation).to receive(:exist?).and_return(false) }

        it { expect(subject.status).to eq 202 }
        it { expect(subject.body).to be_empty }
      end

      context "preset representation exists" do
        it { is_expected.to redirect_to fake_representation_url }
      end
    end

    context "invalid preset" do
      let(:preset) { "unknown" }
      it { expect { subject }.to raise_error ActionController::RoutingError, "Unknown preset 'unknown'" }
    end

    context "invalid sign" do
      let!(:sign_id) { 0 }
      it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
