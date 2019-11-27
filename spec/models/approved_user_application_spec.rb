require "rails_helper"

RSpec.describe ApprovedUserApplication, type: :model do
  subject(:model) { FactoryBot.build(:approved_user_application, id: 1) }
  it { is_expected.to be_valid }

  describe "required fields" do
    before { subject.valid? }

    context "without first_name" do
      subject { FactoryBot.build(:approved_user_application, first_name: "") }
      it { expect(subject.errors[:first_name]).to include("can't be blank") }
    end

    context "without last_name" do
      subject { FactoryBot.build(:approved_user_application, last_name: "") }
      it { expect(subject.errors[:last_name,]).to include("can't be blank") }
    end

    context "without deaf flag set" do
      subject { FactoryBot.build(:approved_user_application, deaf: nil) }
      it { expect(subject.errors[:deaf,]).to include("an answer must be selected") }
    end

    context "without NZSL as first language flag set" do
      subject { FactoryBot.build(:approved_user_application, nzsl_first_language: nil) }
      it { expect(subject.errors[:nzsl_first_language,]).to include("an answer must be selected") }
    end
  end

  context "optional fields" do
    context "ethnicity" do
      it "has options available" do
        expect(Demographics.ethnicities).not_to be_empty
      end

      it "allows a non-predefined value" do
        subject.ethnicity = "Something else"
        expect(subject).to be_valid
      end
    end

    context "gender" do
      it "has options available" do
        expect(Demographics.genders).not_to be_empty
      end

      it "does not allow a non-predefined value" do
        subject.gender = "Something else"
        expect(subject).not_to be_valid
      end
    end
    context "age_bracket" do
      it "has options available" do
        expect(Demographics.age_brackets).not_to be_empty
      end

      it "does not allow a non-predefined value" do
        subject.age_bracket = "Something else"
        expect(subject).not_to be_valid
      end
    end

    context "language roles" do
      it "has options available" do
        expect(Demographics.language_roles).not_to be_empty
      end

      # Handle some misbehaving forms - esp. submissions with JS disabled
      # when fields are not disabled.
      it "removes empty array entries when assigning" do
        subject.language_roles = ["test", "role", ""]
        expect(subject.language_roles).to match_array(%w[test role])
      end

      it "allows a non-predefined value" do
        subject.language_roles << "Something else"
        expect(subject).to be_valid
        expect(subject.language_roles).to include "Something else"
      end
    end
  end

  describe "#status" do
    it "is initially submitted" do
      expect(model.status).to eq "submitted"
    end

    context "accepting" do
      subject { model.accept }

      it "changes the accepted? status of the user" do
        expect { subject }.to change(model, :accepted?).to be true
      end

      it "enqueues a notification that the application has been accepted" do
        expect(ApprovedUserMailer).to receive_message_chain(:accepted, :deliver_later)
        subject
      end

      it "marks the user as approved" do
        expect { subject }.to change(model, :user).to be_approved
      end
    end

    context "declining" do
      subject { model.decline }

      it "does not change the declined? status of the user" do
        expect { subject }.to change(model, :declined?).to be true
      end

      it "enqueues a notification that the application has been approved" do
        expect(ApprovedUserMailer).to receive_message_chain(:declined, :deliver_later)
        subject
      end
    end
  end
end
