require "rails_helper"

RSpec.describe "Editing a sign", type: :system do
  let(:sign) { FactoryBot.create(:sign, :unprocessed) }
  before do
    AuthenticateFeature.new(sign.contributor).sign_in
    visit edit_sign_path(sign)
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

RSpec.describe "Editing sign metadata", type: :system do
  subject { ContributeSignFeature.new }
  let!(:topic) { FactoryBot.create(:topic) }

  before do
    subject.start
    subject.choose_file
    subject.submit
  end

  describe "after uploading a video file as part of the contribution process" do
    it "renders the edit page" do
      expect(subject.current_path).to eq edit_sign_path(Sign.order(created_at: :desc).first)
    end

    it "can successfully enter metadata about a sign" do
      fill_in "sign_word", with: "Dog"
      fill_in "sign_maori", with: "Kuri"
      select topic.name, from: "Topic"
      fill_in "sign_secondary", with: "Canine"
      click_on "Update Sign"
      expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.update.success")
      expect(subject).to have_content "Dog"
      expect(subject).to have_content topic.name
    end

    it "displays validation errors" do
      fill_in "sign_word", with: ""
      click_on "Update Sign"

      expect(subject).to have_content "Edit sign details"
      expect(subject).to have_css ".invalid"
    end
  end

  describe "editing an existing sign" do
    context "owned by the current user" do
      let(:sign) { FactoryBot.create(:sign, contributor: subject.user) }

      it "expect to see an edit button on the sign show page" do
        visit sign_path(sign)
        within ".sign-card__bottom" do
          expect(page).to have_content "Edit"
        end
      end
    end

    context "sign is not owned by the current user" do
      let(:other_user) { FactoryBot.create(:user) }
      let(:other_user_sign) { FactoryBot.create(:sign, contributor: other_user) }

      it "expect not to see an edit button on the sign show page" do
        visit sign_path(other_user_sign)
        within ".sign-card__bottom" do
          expect(page).not_to have_content "Edit"
        end
      end
    end
  end
end
