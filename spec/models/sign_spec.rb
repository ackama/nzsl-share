require "rails_helper"

RSpec.describe Sign, type: :model do
  subject(:sign) { FactoryBot.build(:sign) }

  it { is_expected.to be_valid }

  describe ".preview" do
    before { FactoryBot.create_list(:sign, 5) } # The limit is 4
    subject { Sign.preview }

    it "should have exactly 4 items, even though 5 exist in the table" do
      expect(subject.count).to eq 4
    end
  end
end
