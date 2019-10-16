require "rails_helper"

RSpec.describe VimeoPublisher, type: :service do
  let(:vimeo_client) { double(VimeoClient, post: video_response) }
  let(:blob) { FactoryBot.create(:sign).video.blob }
  let(:default_video_options) { nil } # Fallback to app defaults

  before do
    ActiveJob::Base.queue_adapter = :test
    ActiveStorage::Current.host = "http://example.com"
  end

  subject(:publisher) do
    VimeoPublisher.new(
      client: vimeo_client,
      default_video_options: default_video_options
    )
  end

  describe "#publish" do
    let(:metadata) { { name: "Test video", description: "Test video description" } }
    subject { publisher.publish(blob, metadata) }

    it "sends the expected request to Vimeo" do
      expect(vimeo_client).to receive(:post) do |path, params|
        expect(path).to eq "/me/videos"
        expect(params[:name]).to eq "Test video"
        expect(params[:description]).to eq "Test video description"
        expect(params).to have_key :upload
        expect(params).to include Rails.application.config_for(:vimeo)[:upload_options]

        video_response
      end

      subject
    end

    it "enqueues a job to get the thumbnails for the video" do
      expect { subject }.to have_enqueued_job(VimeoThumbnailsJob).with(blob)
    end

    context "with default video options" do
      let(:default_video_options) { { test_option: true } }

      it "sends the expected request to Vimeo" do
        expect(vimeo_client).to receive(:post) do |path, params|
          expect(path).to eq "/me/videos"
          expect(params).not_to include Rails.application.config_for(:vimeo)[:upload_options]
          expect(params).to include default_video_options
          video_response
        end

        subject
      end
    end
  end

  private

  def video_response
    build_api_response(id: 123, link: "http://vimeo.stub/123")
  end

  def build_api_response(body)
    JSON.parse(body.to_json, object_class: OpenStruct)
  end
end
