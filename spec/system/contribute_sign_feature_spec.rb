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

    it "using drag and drop can contribute a valid video file", uses_javascript: true do
      expect do
        subject.drop_file_in_file_upload
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

      # Until uploading JS is implemented, an alert is opened on direct upload error
      # from rails-ujs. This means that the test (temporarily) needs to expect to see an
      # alert rather than page content when running in JS mode.
      if example.metadata[:uses_javascript]
        sleep 0.5 # Wait for the alert to be visible
        alert = page.driver.browser.switch_to.alert
        expect(alert.text).to eq "Error creating Blob for \"dummy.exe\". Status: 422"
        alert.accept
      else
        subject.click_on("Start Upload")
        expect(subject).to have_error "Video isn't a valid video file"
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
