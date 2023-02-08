require "rails_helper"

RSpec.describe "Contributing a new sign", type: :system do
  let(:user) { FactoryBot.create(:user) }
  subject(:feature) { ContributeSignFeature.new }

  before do
    sign_in user
    feature.start
  end

  it "can navigate to the page from the sidebar" do
    visit root_path
    within ".sidebar--inside-grid" do
      click_on "Add a sign"
    end

    expect(page).to have_current_path(new_sign_path)
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

  it "can upload a single file using Uppy", uses_javascript: true, upload_mode: :uppy do
    expect do
      feature.choose_file(selector: "files[]", visible: false, match: :first)
      click_on "Upload 1 file"
      expect(feature).to have_current_path(%r{\A/signs/\d+/edit})
    end.to change(user.signs, :count).by(1)

    expect(subject).to have_content I18n.t!("signs.create.success")
  end

  it "can drop a single file using Uppy", uses_javascript: true, upload_mode: :uppy do
    expect do
      feature.drop_file(selector: "body")
      click_on "Upload 1 file"
      expect(subject).to have_content I18n.t!("signs.create.success")
    end.to change(user.signs, :count).by(1)
  end

  it "enforces upload restrictions using Uppy", uses_javascript: true, upload_mode: :uppy do
    feature.choose_file("spec/fixtures/dummy.exe", selector: "files[]", visible: false, match: :first)
    expect(page).to have_content("You can only upload: video/*, application/mp4")
  end

  context "when batch contributions are enabled", uses_javascript: true, upload_mode: :uppy do
    let(:user) { FactoryBot.create(:user, batch_sign_contributions_permitted: true, contribution_limit: 2) }

    it "can upload multiple files using Uppy using drag and drop" do
      expect do
        feature.drop_file(selector: "body")
        feature.drop_file("spec/fixtures/small.mp4", selector: "body")
        click_on "Upload 2 files"
        click_on "Edit My Signs >"
        expect(page).to have_current_path(user_signs_path)
      end.to change(user.signs, :count).by(2)
    end

    it "can upload multiple files using Uppy by selecting files" do
      expect do
        feature.choose_file(selector: "files[]", visible: false, match: :first)
        click_on "Add more"
        feature.choose_file("spec/fixtures/small.mp4", selector: "files[]", visible: false, match: :first)
        click_on "Upload 2 files"
        click_on "Edit My Signs >"
        expect(page).to have_current_path(user_signs_path)
      end.to change(user.signs, :count).by(2)
    end

    it "blocks contributions over the limit when uploading multiple files using Uppy" do
      user.signs << FactoryBot.create(:sign)
      feature.start

      feature.drop_file(selector: "body")
      feature.drop_file("spec/fixtures/small.mp4", selector: "body")
      expect(page).to have_content("You can only upload 1 file(s)")
    end
  end

  it "enforces contribution limits" do
    user.update!(contribution_limit: 1)
    user.signs << FactoryBot.create(:sign)
    expected_email = Rails.application.config.contact_email
    feature.start

    expect(subject).to have_current_path root_path
    expect(subject).to have_link expected_email, href: "mailto:#{expected_email}"
    expect(subject).to have_content "
      Sorry, you have reached your video upload limit. Contact #{expected_email} to increase your limit.
    ".strip
  end
end
