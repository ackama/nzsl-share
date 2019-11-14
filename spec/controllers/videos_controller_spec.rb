require "rails_helper"

RSpec.describe VideosController, type: :controller do
  let(:fake_representation_url) { "https://example.com/fake-representation" }
  let(:fake_representation) { double(exist?: true, process_later: true, processed: fake_representation_url) }

  describe "GET #show" do
    let(:blob) { FactoryBot.create(:sign).video.blob }
    let!(:id) { blob.signed_id }
    let(:preset) { "1080p" }

    before do
      allow(CachedVideoTranscoder).to receive(:new).and_return(fake_representation)
    end

    subject { get :show, params: { id: id, preset: preset } }

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

    context "unsigned blob ID" do
      let!(:id) { blob.id }
      it { expect { subject }.to raise_error ActiveSupport::MessageVerifier::InvalidSignature }
    end

    context "unknown blob ID" do
      let!(:id) { 0 }
      it { expect { subject }.to raise_error ActiveSupport::MessageVerifier::InvalidSignature }
    end
  end
end
