require "rails_helper"

RSpec.describe SignAttachmentsController, type: :request do
  let(:sign) { FactoryBot.create(:sign, :with_usage_examples) }
  before { sign_in sign.contributor }

  describe "POST #create" do
    let(:sign_id) { sign.id }
    let(:blob) { generate_blob }
    let(:signed_blob_id) { blob.signed_id }
    let(:attachment_type) { "usage_examples" }
    let(:params) { { sign_id: sign_id, signed_blob_id: signed_blob_id, attachment_type: attachment_type } }

    let(:create_request) { post(sign_attachments_path(params)) }

    context "valid blob" do
      it { expect { create_request }.to change(sign.usage_examples, :count).by(1) }
      it { create_request; expect(response.status).to eq 201 }

      it "post processes the attachment" do
        processor = double
        expect(SignAttachmentPostProcessor).to receive(:new).with(blob).and_return(processor)
        expect(processor).to receive(:process)

        create_request
      end
    end

    context "blob does not exist" do
      let(:signed_blob_id) { "abc123" }
      it { expect { create_request }.to raise_error ActiveSupport::MessageVerifier::InvalidSignature }
    end

    context "sign is invalid" do
      before do
        sign.errors.add(:base, "test error")
        allow(sign).to receive(:valid?).and_return(false)
        allow_any_instance_of(described_class).to receive(:sign).and_return(sign)
      end

      it { expect { create_request }.not_to change(sign.usage_examples, :count) }
      it { create_request; expect(response.status).to eq 422 }
      it { create_request; expect(response.body).to eq "[\"test error\"]" }

      it "does not post process the attachment" do
        expect(SignAttachmentPostProcessor).not_to receive(:new).with(blob)
        create_request
      end
    end

    context "attachment doesn't save" do
      before { allow_any_instance_of(ActiveStorage::Attachment).to receive(:save).and_return(false) }
      it { expect { create_request }.not_to change(sign.usage_examples, :count) }
      it { create_request; expect(response.status).to eq 422 }
    end
  end

  describe "DELETE destroy" do
    let(:attachment) { sign.usage_examples.first }
    let(:destroy_request) { delete(sign_usage_example_path(sign, id: attachment_id)) }

    context "attachment exists" do
      let(:attachment_id) { sign.usage_examples.first.id }
      it { expect { destroy_request }.to change(sign.usage_examples, :count).by(-1) }
      it { destroy_request; expect(response).to redirect_to edit_sign_path(sign) }
    end

    context "attachment does not exist" do
      let(:attachment_id) { 999 }
      it { expect { destroy_request }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "attachment exists but does not belong to the sign" do
      let(:other_sign) { FactoryBot.create(:sign, :with_usage_examples) }
      let(:attachment_id) { other_sign.usage_examples.first.id }
      it { expect { destroy_request }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  private

  def generate_blob
    ActiveStorage::Blob.create_after_upload!(
      io: File.open(Rails.root.join("spec", "fixtures", "dummy.mp4")),
      filename: "stub.fake",
      content_type: "video/mp4"
    )
  end
end