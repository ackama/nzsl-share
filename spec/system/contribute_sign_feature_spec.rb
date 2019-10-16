require "rails_helper"

RSpec.describe "Contributing a new sign", type: :system do
  subject { ContributeSignFeature.new }
  before { subject.start }

  shared_examples_for "sign contribution feature" do
    it "can contribute a valid video file" do
      expect do
        subject.choose_file
        subject.submit
      end.to change(subject.user.signs, :count).by(1)
    end

    it "shows a success message and navigates to the sign page" do
      subject.choose_file
      subject.submit
      expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.create.success")
    end

    it "is prevented from contributing an invalid file", pending: "Waiting for file validations" do
      expect do
        subject.choose_file(Rails.root.join("spec", "fixtures", "dummy.exe"))
        subject.submit
      end.not_to change(subject.user.signs, :count)
    end
  end

  describe "with Javascript disabled" do
    include_examples "sign contribution feature"
  end

  describe "with Javascript enabled", uses_javascript: true do
    include_examples "sign contribution feature"
  end
end
