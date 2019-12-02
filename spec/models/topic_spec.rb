require "rails_helper"

RSpec.describe Topic, type: :model do
  subject(:topic) { FactoryBot.build(:topic) }

  it { is_expected.to be_valid }

  describe ".featured" do
    let(:oldest_featured) { FactoryBot.create(:topic, featured_at: 7.days.ago) }
    let(:newest_featured) { FactoryBot.create(:topic, featured_at: 3.days.ago) }
    let(:non_featured) { FactoryBot.create(:topic) }
    subject { Topic.featured }

    it { is_expected.to eq [newest_featured, oldest_featured] }
    it { is_expected.not_to include non_featured }
  end

  describe "#name" do
    context "blank" do
      subject { FactoryBot.build(:topic, name: "") }
      it { is_expected.not_to be_valid }
    end

    context "duplicate" do
      subject { FactoryBot.build(:topic, name: topic.tap(&:save!).name) }
      it { is_expected.not_to be_valid }
    end
  end

  describe "delete" do
    context "nullify sign" do
      it "destroys the topic and preserves the sign" do
        sign = FactoryBot.create(:sign)
        expect(sign.topic).to be_present
        expect { sign.topic.destroy }.to change { Topic.count }.by(-1)
        expect(sign.reload.topic).to be_nil
      end
    end
  end
end
