require "rails_helper"

RSpec.describe "Contributing a new sign", type: :system do
  let(:user) { FactoryBot.create(:user) }
  subject(:feature) { ContributeSignFeature.new }

  before do
    sign_in user
    feature.start
  end

  it "can select a valid video file in legacy mode", uses_javascript: true, upload_mode: :legacy do
    expect do
      feature.choose_file
      expect(feature).to have_current_path(%r{\A/signs/\d+/edit})
    end.to change(user.signs, :count).by(1)

    expect(subject).to have_content I18n.t!("signs.create.success")
  end

  it "can drop a valid video file in legacy mode", uses_javascript: true, upload_mode: :legacy do
    expect do
      feature.drop_file
      expect(subject).to have_content I18n.t!("signs.create.success")
    end.to change(user.signs, :count).by(1)
  end

  it "is prevented from contributing an invalid file in legacy mode", uses_javascript: true,
                                                                      upload_mode: :legacy do |_example|
    feature.choose_file(Rails.root.join("spec/fixtures/dummy.exe"))
    expect(subject).to have_error "The file you selected does not comply with our upload guidelines."
  end

  it "can upload a file with JS disabled", uses_javacript: false do
    expect do
      feature.choose_file
      feature.submit
    end.to change(user.signs, :count).by(1)

    expect(feature.current_path).to eq edit_sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.create.success")
  end

  it "has the expected page title" do
    expect(subject).to have_title "New Sign – NZSL Share"
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
