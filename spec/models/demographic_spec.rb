require "rails_helper"

RSpec.describe Demographic, type: :model do
  subject { FactoryBot.build(:demographic) }
  it { is_expected.to be_valid }

  describe "required fields" do
    before { subject.valid? }

    context "without first_names" do
      subject { FactoryBot.build(:demographic, first_names: "") }
      it { expect(subject.errors[:first_names]).to include("can't be blank") }
    end

    context "without last_names" do
      subject { FactoryBot.build(:demographic, last_names: "") }
      it { expect(subject.errors[:last_names,]).to include("can't be blank") }
    end

    context "without deaf flag set" do
      subject { FactoryBot.build(:demographic, deaf: nil) }
      it { expect(subject.errors[:deaf,]).to include("is not included in the list") }
    end

    context "without NZSL as first language flag set" do
      subject { FactoryBot.build(:demographic, nzsl_first_language: nil) }
      it { expect(subject.errors[:nzsl_first_language,]).to include("is not included in the list") }
    end
  end

  context "optional fields" do
    context "ethnicity" do
      it "has options available" do
        expect(Demographic.ethnicities).not_to be_empty
      end

      it "allows a non-predefined value" do
        subject.ethnicity = "Something else"
        expect(subject).to be_valid
      end
    end

    context "gender" do
      it "has options available" do
        expect(Demographic.genders).not_to be_empty
      end

      it "does not allow a non-predefined value" do
        subject.gender = "Something else"
        expect(subject).not_to be_valid
      end
    end
    context "age_bracket" do
      it "has options available" do
        expect(Demographic.age_brackets).not_to be_empty
      end

      it "does not allow a non-predefined value" do
        subject.age_bracket = "Something else"
        expect(subject).not_to be_valid
      end
    end

    context "language roles" do
      it "has options available" do
        expect(Demographic.language_roles).not_to be_empty
      end

      it "allows a non-predefined value" do
        subject.language_roles << "Something else"
        expect(subject).to be_valid
        expect(subject.language_roles).to include "Something else"
      end
    end
  end
end
