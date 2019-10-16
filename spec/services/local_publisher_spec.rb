require "rails_helper"

RSpec.describe LocalPublisher, type: :service do
  let(:blob) { FactoryBot.create(:sign).video }
  describe "#publish" do
    it "generates expected thumbnails for the attachment" do
      expect { subject.publish(blob) }
        .to change(ActiveStorage::Blob, :count)
        .by(described_class::THUMBNAIL_SIZES.size)
    end

    it "doesn't set any metadata on the attachment" do
      expect { subject.publish(blob) }.not_to change(blob, :metadata)
    end
  end
end
