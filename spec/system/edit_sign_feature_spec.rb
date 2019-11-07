require "rails_helper"

RSpec.describe "Editing a sign", type: :system do
  let!(:topic) { FactoryBot.create(:topic) }
  let(:sign) { FactoryBot.create(:sign, :unprocessed) }
  subject { page }

  before do
    AuthenticateFeature.new(sign.contributor).sign_in
    visit edit_sign_path(sign)
  end

  it "renders the edit page" do
    expect(subject.current_path).to eq edit_sign_path(Sign.order(created_at: :desc).first)
  end

  it "shows the expected page title" do
    expect(subject).to have_title "Edit '#{sign.word}' – NZSL Share"
  end

  it "can successfully enter metadata about a sign" do
    fill_in "sign_word", with: "Dog"
    fill_in "sign_maori", with: "Kuri"
    select topic.name, from: "Topic"
    fill_in "sign_secondary", with: "Canine"
    choose "should_submit_for_publishing_true"
    check "sign_conditions_accepted"
    click_on "Update Sign"
    sign.reload
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(subject).to have_content "Dog"
    expect(subject).to have_content topic.name
    expect(sign.submitted?).to eq true
  end

  it "can update a private sign without accepting the conditions" do
    choose "should_submit_for_publishing_false"
    click_on "Update Sign"
    sign.reload
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(sign.submitted?).to eq false
  end

  it "cannot request a sign be made public without accepting the conditions" do
    choose "should_submit_for_publishing_true"
    click_on "Update Sign"
    sign.reload
    expect(subject).to have_content sign.errors.generate_message(:conditions_accepted, :blank)
    expect(sign.submitted?).to eq false
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

  describe "removing a sign" do
    before { click_on "Remove from NZSL Share" }

    it { expect { sign.reload }.to raise_error ActiveRecord::RecordNotFound }
    it { expect(current_path).to eq user_signs_path }
    it { expect(page).to have_content "Your sign, '#{sign.word}' has been removed from NZSL Share" }

    it "confirms before deleting", uses_javascript: true do
      confirmation = page.driver.browser.switch_to.alert
      expect(confirmation.text).to eq I18n.t!("signs.destroy.confirm")
    end
  end

  describe "video processing", uses_javascript: true do
    subject { page.find(".sign-video") }

    context "when the video is unprocessed" do
      it { expect(page).to have_selector ".sign-video[poster*=processing]" }
    end

    context "when the sign video has had thumbnails generated" do
      before { sign.update!(processed_thumbnails: true); }
      it { expect(page).to have_selector ".sign-video[poster*='/rails/active_storage/']" }
    end

    context "when the sign video has been encoded" do
      before { sign.update!(processed_thumbnails: true, processed_videos: true); }
      it { expect(subject).to have_selector("source[src*='/signs/#{sign.id}/videos']", count: 3, visible: false) }
    end
  end

  shared_examples_for "sign attachment behaviour" do |attribute|
    let(:field_name) { "sign_#{attribute}" }
    let(:container_name) { ".#{field_name.tr("_", "-")}" }

    context "without JS" do
      it "sees existing attachment data" do
        single_record = sign.public_send(attribute).first
        within(container_name) do
          expect(page).to have_content single_record.filename
          expect(page).to have_content "1 MB" # Known file size
          expect(page).to have_button "Remove File"
        end
      end

      it "can remove a file" do
        within(container_name) do
          expect(page).to have_selector "li", count: 1
          click_on "Remove File"
          expect(page).not_to have_selector "li"
        end
      end

      it "can upload a new file" do
        page.attach_file field_name, valid_file
        click_on "Update Sign"
        click_on "Edit"
        expect(page).to have_selector "#{container_name} li", count: 1
      end

      it "rejects an invalid file with an error" do
        page.attach_file field_name, Rails.root.join("spec", "fixtures", "dummy.exe")
        click_on "Update Sign"
        expect(page).to have_selector "input##{field_name}.invalid + div", text: "file is not of an accepted type"
      end
    end

    context "with JS", uses_javascript: true do
      it "can remove a file"
      it "can upload a new file"
    end
  end

  describe "usage examples" do
    let(:sign) { FactoryBot.create(:sign, :with_usage_examples) }
    let(:valid_file) { Rails.root.join("spec", "fixtures", "dummy.mp4") }
    include_examples "sign attachment behaviour", :usage_examples
  end

  describe "illustrations" do
    let(:sign) { FactoryBot.create(:sign, :with_illustrations) }
    let(:valid_file) { Rails.root.join("spec", "fixtures", "image.jpeg") }
    include_examples "sign attachment behaviour", :illustrations
  end
end
