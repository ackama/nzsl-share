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

  it "displays validation errors" do
    fill_in "sign_word", with: ""
    click_on "Update Sign"

    expect(subject).to have_content "Edit sign details"
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
end
