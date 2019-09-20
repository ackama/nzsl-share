require "rails_helper"

RSpec.describe Sign, type: :model do
  describe "validations" do
    it { expect(subject).to validate_length_of(:english) }
    it { expect(subject).to validate_length_of(:maori) }
  end
end
