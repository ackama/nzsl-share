require "rails_helper"

RSpec.describe SignPublishVideoJob, type: :job do
  let(:sign) { double(Sign) }
  let(:publisher) { double(SignVideoPublisher) }

  it "publishes the sign video" do
    expect(publisher).to receive(:publish).with(sign)
    SignPublishVideoJob.perform_now(sign, publisher: publisher)
  end
end
