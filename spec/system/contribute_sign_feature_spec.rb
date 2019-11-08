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

    it "using drag and drop can contribute a valid video file" do
      expect do
        subject.drop_file_in_file_upload
        subject.submit
      end.to change(subject.user.signs, :count).by(1)
    end

    it "shows a success message and navigates to the sign page" do
      subject.choose_file
      subject.submit
      expect(subject.current_path).to eq edit_sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.create.success")
    end

    it "is prevented from contributing an invalid file" do |example|
      subject.choose_file(Rails.root.join("spec", "fixtures", "dummy.exe"))

      # Until uploading JS is implemented, an error is shown using the raw direct upload error
      # from rails-ujs. This means that the test (temporarily) needs to expect to see an
      # technical rather than useful error message when running in JS mode.
      if example.metadata[:uses_javascript]
        expect(subject).to have_error "Error creating Blob for \"dummy.exe\". Status: 422"
      else
        subject.click_on("Start Upload")
        expect(subject).to have_error "Video file is not of an accepted type"
      end
    end
  end

  it "has the expected page title" do
    expect(subject).to have_title "New Sign – NZSL Share"
  end

  describe "with Javascript disabled" do
    include_examples "sign contribution feature"
  end

  describe "with Javascript enabled", uses_javascript: true do
    include_examples "sign contribution feature"
  end
end
