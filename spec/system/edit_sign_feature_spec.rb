require "rails_helper"

RSpec.describe "Editing a sign", type: :system do
  include FileUploads
  include WaitForAjax
  include ActionView::Helpers::NumberHelper

  let!(:topic) { FactoryBot.create(:topic) }
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :unprocessed, contributor: user) }
  subject { page }

  before do
    sign_in user
    visit edit_sign_path(sign)
  end

  it "renders the edit page" do
    expect(subject.current_path).to eq edit_sign_path(sign)
  end

  it "shows the destroy button to contributors for private signs" do
    expect(subject).to have_content "Remove from NZSL Share"
    expect(subject).to have_no_content "Unpublish"
  end

  context "moderator signed in" do
    let(:user) { FactoryBot.create(:user, :moderator) }
    let(:sign) { FactoryBot.create(:sign, :published) }

    it "renders the edit page" do
      expect(subject.current_path).to eq edit_sign_path(sign)
    end

    it "shows the unpublish button" do
      expect(subject).to have_content "Unpublish"
      expect(subject).to have_no_content "Remove from NZSL Share"
    end
  end

  it "shows the expected page title" do
    expect(subject).to have_title "Edit '#{sign.word}' – NZSL Share"
  end

  it "can successfully enter metadata about a sign" do
    fill_in "sign_word", with: "Dog"
    fill_in "sign_maori", with: "Kuri"
    select topic.name, from: "sign_topic_ids"
    fill_in "sign_secondary", with: "Canine"
    choose "should_submit_for_publishing_true"
    check "sign_conditions_accepted"
    click_on "Update Sign"
    sign.reload
    expect(sign.topics.find_by(id: topic.id)).to eq topic
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(subject).to have_content "Dog"
    expect(sign.submitted?).to eq true
  end

  context "non-approved user" do
    let(:user) { FactoryBot.create(:user) }

    it "doesn't see the conditions" do
      expect(page).to have_no_selector "#privacy-policy"
    end

    it "doesn't have an option to submit for publishing" do
      expect(page).to have_no_field "Yes, request my sign be public"
    end

    it "can update a private sign" do
      click_on "Update Sign"
      sign.reload
      expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.update.success")
    end
  end

  it "can update a private sign without accepting the conditions" do
    choose "No, keep my sign private"
    click_on "Update Sign"
    sign.reload
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(sign.submitted?).to eq false
  end

  it "cannot request a sign be made public without accepting the conditions" do
    choose "Yes, I want my sign to be public"
    click_on "Update Sign"
    sign.reload
    expect(subject).to have_content sign.errors.generate_message(:conditions_accepted, :blank)
    expect(sign.submitted?).to eq false
  end

  context "sign is submitted" do
    let(:sign) { FactoryBot.create(:sign, :submitted, contributor: user) }

    it "can update the sign" do
      click_on "Update Sign"
      sign.reload
      expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.update.success")
      expect(sign.submitted?).to eq true
    end
  end

  it "hides the privacy policy with JS unless they are required to be accepted", uses_javascript: true do
    expect(page).to have_selector "#privacy-policy", visible: false
    choose "Yes, I want my sign to be public"
    expect(page).to have_selector "#privacy-policy", visible: true
  end

  it "displays information about the video belonging to the sign" do
    within ".file-preview" do
      expect(subject).to have_content "dummy.mp4"
      expect(subject).to have_content "1 MB"
    end
  end

  it "displays validation errors" do
    fill_in "sign_word", with: ""
    click_on "Update Sign"

    expect(subject).to have_content "Edit sign"
    expect(subject).to have_css ".invalid"
  end

  it "can remove a sign" do
    expect do
      click_on "Remove from NZSL Share"
      expect(current_path).to eq user_signs_path
    end.to change(user.signs, :count).by(-1)

    expect(page).to have_content "Your sign, '#{sign.word}' has been removed from NZSL Share"
  end

  it "confirms before deleting", uses_javascript: true do
    click_on "Remove from NZSL Share"
    confirmation = page.driver.browser.switch_to.alert
    expect(confirmation.text).to eq I18n.t!("signs.destroy.confirm")
  end

  describe "video processing", uses_javascript: true do
    context "when the video is unprocessed" do
      it { expect(page).to have_selector ".video[poster*=processing]" }
    end

    context "when the sign video has had thumbnails generated" do
      it "displays the processed thumbnail" do
        sign.update!(processed_thumbnails: true)
        visit sign_path(sign)
        expect(page).to have_selector(".video[poster*='/rails/active_storage/']")
      end
    end

    context "when the sign video has been encoded" do
      let(:sign) { FactoryBot.create(:sign, :processed_thumbnails, :processed_videos, contributor: user) }

      it {
        expect(subject).to have_selector("source[src*='/videos']", count: 3, visible: false)
      }
    end
  end

  it "shows usage examples for a sign" do
    attachment_1 = fixture_file_upload("spec/fixtures/small.mp4")
    attachment_2 = fixture_file_upload("spec/fixtures/medium.mp4")
    sign.usage_examples.attach(attachment_1)
    sign.usage_examples.attach(attachment_2)
    visit edit_sign_path(sign)

    within ".sign-usage-examples" do
      expect(page).to have_content attachment_1.original_filename
      expect(page).to have_content number_to_human_size(attachment_1.size)
      expect(page).to have_content attachment_2.original_filename
      expect(page).to have_content number_to_human_size(attachment_2.size)
      expect(page).to have_button "Remove File", count: 2
    end
  end

  it "can update the description of a usage example", uses_javascript: true do
    attachment = fixture_file_upload("spec/fixtures/small.mp4")
    sign.usage_examples.attach(attachment)
    visit edit_sign_path(sign)
    desc = "New usage example description"

    within(".sign-usage-examples li") do
      field = find_field(:description)
      field.send_keys desc, :return
    end

    wait_for_ajax
    visit current_path

    within(".sign-usage-examples li") do
      expect(page).to have_field :description, with: desc
    end
  end

  it "can update the description of a usage example without JS" do
    attachment = fixture_file_upload("spec/fixtures/small.mp4")
    sign.usage_examples.attach(attachment)
    visit edit_sign_path(sign)
    desc = "New usage example description"

    within(".sign-usage-examples li") do
      fill_in :description, with: desc
      page.find("input[type=submit]", visible: false).click
    end

    visit current_path

    within(".sign-usage-examples li") do
      expect(page).to have_field :description, with: desc
    end
  end

  it "can remove a usage example", uses_javascript: true do
    attachment = fixture_file_upload("spec/fixtures/small.mp4")
    sign.usage_examples.attach(attachment)
    visit edit_sign_path(sign)

    expect do
      within(".sign-usage-examples li") { click_on("Remove File") }
      expect(page).not_to have_selector(".sign-usage-examples li")
    end.to change(sign.usage_examples, :count).by(-1)

    expect(page).not_to have_selector ".sign-usage-examples li"
  end

  it "can remove a usage example without JS", uses_javascript: false do
    attachment = fixture_file_upload("spec/fixtures/small.mp4")
    sign.usage_examples.attach(attachment)
    visit edit_sign_path(sign)

    expect do
      within(".sign-usage-examples li") { find(".show-if-no-js", text: "Remove File").click }
    end.to change(sign.usage_examples, :count).by(-1)

    expect(page).not_to have_selector ".sign-usage-examples li"
  end

  it "can specify usage examples for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".usage-examples" do
      click_on "Upload files"

      # Invalid file has an error
      choose_file Rails.root.join("spec/fixtures/dummy.exe"), selector: "files[]", visible: false, match: :first
      expect(page).to have_content "You can only upload: video/*"

      # Block too many files
      choose_file selector: "files[]", visible: false, match: :first
      click_on "Add more"
      choose_file Rails.root.join("spec/fixtures/small.mp4"), selector: "files[]", visible: false, match: :first
      expect(page).not_to have_button "Add more"

      click_on "Upload 2 files"
    end

    expect(page).to have_selector(".sign-usage-examples > *", count: 2)
  end

  it "can drag and drop usage examples for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".usage-examples" do
      click_on "Upload files"
      expect(page).to have_selector(".uppy-Dashboard")
      drop_file Rails.root.join("spec/fixtures/dummy.exe"), selector: ".uppy-Dashboard"
      expect(page).to have_content "You can only upload: video/*"

      drop_file(selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/small.mp4", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/medium.mp4", selector: ".uppy-Dashboard")
      expect(page).to have_content "You can only upload 2 files"

      click_on "Upload 2 files"
    end

    expect(page).to have_selector(".sign-usage-examples > *", count: 2)
  end

  it "can specify usage examples for a sign without javascript", uses_javacript: false do
    within(".usage-examples") { choose_file }
    click_on "Update Sign"
    expect(page).to have_content I18n.t("signs.update.success")
    visit edit_sign_path(sign)
    expect(page).to have_selector(".sign-usage-examples > *")
  end

  it "can specify usage examples for a sign using the legacy uploader", uses_javascript: true, upload_mode: :legacy do
    within ".usage-examples" do
      choose_file
      expect(page).to have_selector(".sign-usage-examples > *", count: 1)
      choose_file Rails.root.join("spec/fixtures/small.mp4")
      expect(page).to have_selector(".sign-usage-examples > *", count: 2)
    end
  end

  it "can specify illustrations for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".illustrations" do
      click_on "Upload files"

      # Invalid file has an error
      choose_file Rails.root.join("spec/fixtures/dummy.exe"), selector: "files[]", visible: false, match: :first
      expect(page).to have_content "You can only upload: image/*"

      # Block too many files
      choose_file Rails.root.join("spec/fixtures/image.png"), selector: "files[]", visible: false, match: :first
      click_on "Add more"
      choose_file Rails.root.join("spec/fixtures/image.jpeg"), selector: "files[]", visible: false, match: :first
      click_on "Add more"
      choose_file Rails.root.join("spec/fixtures/image.gif"), selector: "files[]", visible: false, match: :first
      expect(page).not_to have_button "Add more"

      click_on "Upload 3 files"
    end

    expect(page).to have_selector(".sign-illustrations > *", count: 3)
  end

  it "can drag and drop illustrations for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".illustrations" do
      click_on "Upload files"
      expect(page).to have_selector(".uppy-Dashboard")
      drop_file Rails.root.join("spec/fixtures/dummy.exe"), selector: ".uppy-Dashboard"
      expect(page).to have_content "You can only upload: image/*"

      drop_file("spec/fixtures/image.png", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.jpeg", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.gif", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.webp", selector: ".uppy-Dashboard")
      expect(page).to have_content "You can only upload 3 files"

      click_on "Upload 3 files"
    end

    expect(page).to have_selector(".sign-illustrations > *", count: 3)
  end

  it "can specify illustrations for a sign without javascript", uses_javacript: false do
    within(".illustrations") { choose_file Rails.root.join("spec/fixtures/image.png") }
    click_on "Update Sign"
    expect(page).to have_content I18n.t("signs.update.success")
    visit edit_sign_path(sign)
    expect(page).to have_selector(".sign-illustrations > *")
  end

  it "can specify illustrations for a sign using the legacy uploader", uses_javascript: true, upload_mode: :legacy do
    within ".illustrations" do
      choose_file Rails.root.join("spec/fixtures/image.png")
      expect(page).to have_selector(".sign-illustrations > *", count: 1)
      choose_file Rails.root.join("spec/fixtures/image.jpeg")
      expect(page).to have_selector(".sign-illustrations > *", count: 2)
      choose_file Rails.root.join("spec/fixtures/image.gif")
      expect(page).to have_selector(".sign-illustrations > *", count: 3)
    end
  end

  describe "Updating the video on a sign", uses_javascript: true do
    it "can update the video using file selection" do
      click_on "Change video"
      choose_file(selector: "files[]", visible: false, match: :first)
      expect do
        click_on "Upload 1 file"
        expect(page).to have_content(I18n.t("signs.update.success"))
        sign.reload
      end.to change(sign, :video_blob)
    end

    it "can update the video using drag and drop" do
      click_on "Change video"
      drop_file(selector: "body")
      expect do
        click_on "Upload 1 file"
        expect(page).to have_content(I18n.t("signs.update.success"))
        sign.reload
      end.to change(sign, :video_blob)
    end
  end
end
