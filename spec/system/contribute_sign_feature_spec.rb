require "rails_helper"

RSpec.describe "Contributing a new sign", type: :system do
  let(:user) { FactoryBot.create(:user) }
  subject { ContributeSignFeature.new }
  before { subject.start(user) }

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
        expect(subject).to have_content I18n.t!("signs.create.success")
      end.to change(subject.user.signs, :count).by(1)
    end

    it "shows a success message and navigates to the sign page" do
      subject.choose_file
      subject.submit
      expect(subject.current_path).to eq edit_sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.create.success")
    end

    it "is prevented from contributing an invalid file" do |example|
      subject.choose_file(Rails.root.join("spec/fixtures/dummy.exe"))

      # Until uploading JS is implemented, an error is shown using the raw direct upload error
      # from rails-ujs. This means that the test (temporarily) needs to expect to see an
      # technical rather than useful error message when running in JS mode.
      if example.metadata[:uses_javascript]
        expect(subject).to have_error "The file you selected does not comply with our upload guidelines."
      else
        subject.click_on("Start Upload")
        expect(subject).to have_error "Video file is not of an accepted type"
      end
    end
  end

  it "has the expected page title" do
    expect(subject).to have_title "New Sign – NZSL Share"
  end

  context "with Javascript disabled" do
    include_examples "sign contribution feature"
  end

  context "with Javascript enabled", uses_javascript: true do
    include_examples "sign contribution feature"
  end

  context "exceeding contribution limit" do
    let(:user) do
      FactoryBot.create(:user, contribution_limit: 1).tap do |user|
        user.contribution_limit.times do
          user.signs << FactoryBot.create(:sign)
        end
      end
    end

    it { expect(subject).to have_current_path root_path }

    it "renders a message informing the user to contact NZSL" do
      expected_email = Rails.application.config.contact_email
      expect(subject).to have_content "
        Sorry, you have reached your video upload limit. Contact #{expected_email} to increase your limit.
      ".strip
      expect(subject).to have_link expected_email, href: "mailto:#{expected_email}"
    end
  end
end
