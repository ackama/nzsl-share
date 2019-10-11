require "rails_helper"

RSpec.describe Folder, type: :model do
  subject(:model) { FactoryBot.build(:folder) }

  it { is_expected.to be_valid }

  describe "#title" do
    context "missing" do
      subject { FactoryBot.build(:folder, title: "") }
      it { is_expected.not_to be_valid }
    end

    context "duplicate with a different user" do
      subject { FactoryBot.build(:folder, title: model.tap(&:save!).title) }
      it { is_expected.to be_valid }
    end

    context "duplicate with the same user" do
      before { model.save! }
      subject { FactoryBot.build(:folder, user: model.user, title: model.title) }
      it { is_expected.not_to be_valid }
    end
  end
end
