require "rails_helper"

RSpec.describe SurfaceError, type: :service do
  message = "an informative message"

  describe "log" do
    it "puts the message in rails logger" do
      expect(Rails.logger).to receive(:error).with(message)
      described_class.new(message).log
    end

    it "gives the message to RayGun" do
      expect(Raygun).to receive(:track_exception).with(Exception.new(message))
      described_class.new(message).log
    end
  end
end
