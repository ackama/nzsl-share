require "rails_helper"

RSpec.describe PublishedSignsExport, type: :service do
  subject(:export) { described_class.new }

  describe ".results" do
    it "includes the expected data"
  end

  describe ".to_csv" do
    it "builds the expected CSV structure"
  end
end
