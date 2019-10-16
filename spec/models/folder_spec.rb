require "rails_helper"

RSpec.describe Folder, type: :model do
  subject(:model) { FactoryBot.build(:folder) }

  it { is_expected.to be_valid }

  describe "#title=" do
    it "strips whitespace" do
      expect { model.title = "\t\t  My title !   \n" }.to change(model, :title).to "My title !"
    end
  end

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

    context "duplicate with different case" do
      before { model.save! }
      subject { FactoryBot.build(:folder, user: model.user, title: model.title.upcase) }
      it { is_expected.not_to be_valid }
    end

    context "duplicate with leading space" do
      before { model.save! }
      subject { FactoryBot.build(:folder, user: model.user, title: " #{model.title}") }
      it { is_expected.not_to be_valid }
    end

    context "duplicate with trailing space" do
      before { model.save! }
      subject { FactoryBot.build(:folder, user: model.user, title: "#{model.title} ") }
      it { is_expected.not_to be_valid }
    end
  end
end
