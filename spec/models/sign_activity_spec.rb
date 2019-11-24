require "rails_helper"

RSpec.describe SignActivity, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:sign) { FactoryBot.create(:sign) }
  subject(:model) { FactoryBot.build(:sign_activity) }

  it "belongs to a user" do
    expect(model.user).to be_a User
  end

  it "belongs to a sign" do
    expect(model.sign).to be_a Sign
  end

  describe ".for_type" do
    subject { SignActivity.for_type("test", user: user) }
    it "uses the expected type" do
      expect(subject.key).to eq "test"
    end

    it "adds the expected attributes" do
      expect(subject.user).to eq user
    end
  end

  describe ".agreement" do
    subject { SignActivity.agreement(user: user) }
    it "uses the expected type" do
      expect(subject.key).to eq SignActivity::ACTIVITY_AGREE
    end

    it "adds the expected attributes" do
      expect(subject.user).to eq user
    end
  end

  describe ".disagreement" do
    subject { SignActivity.disagreement(user: user) }
    it "uses the expected type" do
      expect(subject.key).to eq SignActivity::ACTIVITY_DISAGREE
    end

    it "adds the expected attributes" do
      expect(subject.user).to eq user
    end
  end

  describe ".agree?" do
    let(:attrs) { { user: user, sign: sign } }
    subject { SignActivity.agree?(attrs) }
    context "the user has agreed" do
      before { SignActivity.agreement(attrs).tap(&:save!) }
      it { is_expected.to eq true }
    end

    context "the user has not agreed" do
      it { is_expected.to eq false }
    end
  end

  describe ".disagree?" do
    let(:attrs) { { user: user, sign: sign } }
    subject { SignActivity.disagree?(attrs) }

    context "the user has disagreed" do
      before { SignActivity.disagreement(attrs).tap(&:save!) }
      it { is_expected.to eq true }
    end

    context "the user has not disagreed" do
      it { is_expected.to eq false }
    end
  end

  describe ".agree!" do
    let(:attrs) { { user: user, sign: sign } }
    subject { SignActivity.agree!(attrs) }

    it { expect { subject }.to change { SignActivity.agree?(attrs) }.from(false).to(true) }

    context "already agreed" do
      before { SignActivity.agree!(attrs) }
      it { expect { subject }.not_to change(SignActivity, :count) }
    end

    context "disagreed" do
      before { SignActivity.disagree!(attrs) }
      it "swaps the disagree to agree" do
        expect { subject }.to change { SignActivity.disagree?(attrs) }
          .from(true).to(false)
          .and change { SignActivity.agree?(attrs) }
          .from(false).to(true)
      end
    end
  end

  describe ".disagree!" do
    let(:attrs) { { user: user, sign: sign } }
    subject { SignActivity.disagree!(attrs) }

    it { expect { subject }.to change { SignActivity.disagree?(attrs) }.from(false).to(true) }

    context "already disagreed" do
      before { SignActivity.disagree!(attrs) }
      it { expect { subject }.not_to change(SignActivity, :count) }
    end

    context "disagreed" do
      before { SignActivity.agree!(attrs) }
      it "swaps the agree to disagree" do
        expect { subject }.to change { SignActivity.agree?(attrs) }
          .from(true).to(false)
          .and change { SignActivity.disagree?(attrs) }
          .from(false).to(true)
      end
    end
  end
end
