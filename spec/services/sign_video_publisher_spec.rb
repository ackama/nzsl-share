require "rails_helper"

RSpec.describe SignVideoPublisher, type: :service do
  let(:publisher) { double(LocalPublisher) }
  let(:sign) { FactoryBot.build_stubbed(:sign) }

  subject(:service) { described_class.new(publisher: publisher) }

  describe "#publish" do
    subject { service.publish(sign) }
    it "invokes the publisher with the expected blob" do
      expect(publisher).to receive(:publish).with(an_instance_of(ActiveStorage::Blob), any_args)
      subject
    end

    it "invokes the publisher with the expected metadata" do
      expect(publisher).to receive(:publish) do |_blob, metadata|
        expect(metadata[:name]).to eq "NZSL Share: Contributed sign for '#{sign.english}'"
        expect(metadata[:description]).to eq "
          Video contributed to NZSL Share. More information: http://localhost:3000/signs/#{sign.id}
        ".strip
      end

      subject
    end
  end
end
