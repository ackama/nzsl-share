require "rails_helper"

RSpec.describe "Editing sign usage examples", type: :system do
  include FileUploads
  include WaitForAjax
  include ActionView::Helpers::NumberHelper

  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :unprocessed, contributor: user) }
  subject { page }

  before do
    sign_in user
    visit edit_sign_path(sign)
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
      expect(page).to have_content "You can only upload 2 file(s) at a time"

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
end
