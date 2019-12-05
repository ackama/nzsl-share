require "rails_helper"

RSpec.describe User, type: :model do
  subject(:model) { FactoryBot.build(:user) }

  it { is_expected.to be_valid }

  describe "#username" do
    context "missing" do
      subject { FactoryBot.build(:user, username: "") }
      it { is_expected.not_to be_valid }
    end

    context "duplicate" do
      subject { FactoryBot.build(:user, username: model.tap(&:save!).username) }
      it { is_expected.not_to be_valid }
    end

    context "duplicate, different case" do
      subject { FactoryBot.build(:user, username: model.tap(&:save!).username.upcase) }
      it { is_expected.not_to be_valid }
    end

    context "with email spoofing" do
      subject { FactoryBot.build(:user, username: "test@example.com") }
      it { is_expected.not_to be_valid }
    end

    context "saved lowercase" do
      subject { FactoryBot.create(:user, username: "SPAGSAUCEUSER") }
      it { expect(subject.username).to eq "spagsauceuser" }
    end
  end

  describe ".find_for_database_authentication" do
    subject { User.find_for_database_authentication(conditions) }

    context "without a login key" do
      let(:conditions) { { unknown_key: true } }
      it { expect { subject }.to raise_error(/^Expected Warden conditions to include :login and it did not/) }
    end

    context "user exists (username)" do
      let(:conditions) { { login: model.tap(&:save!).username } }
      it { is_expected.to eq model }
    end

    context "user exists (email)" do
      let(:conditions) { { login: model.tap(&:save!).email } }
      it { is_expected.to eq model }
    end

    context "user does not exist" do
      let(:conditions) { { login: Faker::Internet.username } }
      it { is_expected.to eq nil }
    end

    context "user exists (given uppercase username)" do
      let(:conditions) { { login: model.tap(&:save!).username.upcase } }
      it { is_expected.to eq model }
    end
  end

  describe "#contribution_limit_reached?" do
    let(:contribution_limit) { 10 }
    let(:signs_count) { 0 }
    let(:user) { FactoryBot.build(:user, contribution_limit: contribution_limit) }
    before { allow(user.signs).to receive(:count).and_return(signs_count) }
    subject { user.contribution_limit_reached? }

    context "under limit" do
      it { is_expected.to eq false }
    end

    context "on limit" do
      let(:signs_count) { contribution_limit }
      it { is_expected.to eq true }
    end

    context "over limit" do
      let(:signs_count) { contribution_limit + 1 }
      it { is_expected.to eq true }
    end
  end

  describe ".avatar" do
    subject { FactoryBot.create(:user, :with_avatar) }
    it { expect(subject.avatar).to be_an_instance_of(ActiveStorage::Attached::One) }

    context "with a valid file" do
      it { is_expected.to be_valid }
    end

    context "blank" do
      before { subject.avatar = nil }
      it { is_expected.to be_valid }
    end

    context "too large" do
      let(:invalid_blob_size) { 500.megabytes }
      before do
        allow(subject.avatar.blob).to receive(:byte_size) { invalid_blob_size }
        subject.valid?
      end

      it { is_expected.not_to be_valid }
    end

    context "wrong type" do
      let(:invalid_content_type) { "application/pdf" }
      before do
        allow(subject.avatar.blob).to receive(:content_type) { invalid_content_type }
        subject.valid?
      end
      it { is_expected.not_to be_valid }
    end
  end
end
