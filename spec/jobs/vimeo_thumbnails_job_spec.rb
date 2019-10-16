require "rails_helper"

RSpec.describe VimeoThumbnailsJob, type: :job do
  let(:vimeo_client) { double(VimeoClient) }
  let(:blob) do
    blob = FactoryBot.create(:sign).video
    blob.metadata[:vimeo] = { id: 123, link: "https://stub.vimeo/123" }
    blob.blob
  end

  before do
    ActiveJob::Base.queue_adapter = :test
    allow_any_instance_of(described_class)
      .to receive(:vimeo_client)
      .and_return(vimeo_client)
  end

  subject { VimeoThumbnailsJob.perform_now(blob) }

  context "thumbnails are not ready" do
    before { allow(vimeo_client).to receive(:get).and_return(inactive_response) }

    it "re-queues the job" do
      expect { subject }.to have_enqueued_job(described_class).with(blob)
    end
  end

  context "blob is not stored in Vimeo" do
    let(:blob) { FactoryBot.create(:sign).video }

    it "returns without processing the job" do
      expect(vimeo_client).not_to receive(:get)
      subject
    end
  end

  it "processes the expected variants" do
    allow(vimeo_client).to receive(:get).and_return(active_response)
    expect { subject }.to change(ActiveStorage::Blob, :count).by(1)
  end

  it "doesn't reprocess variants that already exist" do
    allow(vimeo_client).to receive(:get).and_return(active_response)
    subject
    expect { subject }.not_to change(ActiveStorage::Blob, :count)
  end

  private

  def active_response
    build_api_response(
      data: {
        active: true,
        sizes: [
          width: 100,
          height: 50,
          link: "http://placehold.it/300x300.jpg"
        ]
      }
    )
  end

  def inactive_response
    build_api_response(data: { active: false })
  end

  def build_api_response(body)
    JSON.parse(body.to_json, object_class: OpenStruct)
  end
end
