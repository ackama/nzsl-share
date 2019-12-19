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

  describe "associated signs" do
    it "destroy the topic not the sign" do
      sign = FactoryBot.create(:sign)
      expect(sign.topics).to be_present
      expect(sign.topics.count).to eq SignTopic.count
      expect { sign.topics.first.destroy }.to change { Topic.count }.by(-1)
      expect(sign.topics.count).to eq 0
      expect(sign.reload.topics).to eq []
    end

    it "destroy the sign not the topic" do
      sign = FactoryBot.create(:sign)
      expect(sign.topics).to be_present
      expect(sign.topics.count).to eq SignTopic.count
      expect { sign.destroy! }.to change { Topic.count }.by(0)
      expect(SignTopic.count).to eq 0
      expect { sign.reload }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
