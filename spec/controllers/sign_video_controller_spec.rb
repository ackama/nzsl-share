require "rails_helper"

RSpec.describe SignVideoController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:fake_representation_url) { "https://example.com/fake-representation" }
  let(:fake_representation) { double(exist?: true, process_later: true, processed: fake_representation_url) }

  describe "GET #show" do
    let(:sign) { FactoryBot.create(:sign) }
    let(:user) { sign.contributor }
    let!(:sign_id) { sign.id }
    let(:preset) { "1080p" }

    before do
      allow(CachedVideoTranscoder).to receive(:new).and_return(fake_representation)
      sign_in user if user
    end

    subject { get :show, params: { sign_id: sign_id, preset: preset } }

    context "valid params" do
      context "preset representation does not exist" do
        before { allow(fake_representation).to receive(:exist?).and_return(false) }

        it { expect(subject.status).to eq 202 }
        it { expect(subject.body).to be_empty }

        it "enqueues a job to transcode the missing representation" do
          expect(fake_representation).to receive(:process_later)
          subject
        end
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

    context "different user signed in" do
      let(:user) { FactoryBot.create(:user) }
      it { expect(subject.status).to eq 403 }
    end

    context "user not signed in" do
      let(:user) { nil }
      context "sign is published" do
        let(:sign) { FactoryBot.create(:sign, :published) }
        it { is_expected.to redirect_to fake_representation_url }
      end

      context "sign is not published" do
        it { expect(subject.status).to eq 403 }
      end
    end
  end
end
