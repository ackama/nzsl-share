require "rails_helper"

RSpec.describe "Sign show page", system: true do
  let(:user) { sign.contributor }
  let(:sign) { FactoryBot.create(:sign) }
  let(:auth) { AuthenticateFeature.new(user) }
  subject(:sign_page) { SignPage.new }

  before do
    auth.sign_in if user
    sign_page.start(sign)
  end

  it "displays the sign word" do
    expect(subject).to have_selector "h2", text: sign.word
  end

  it "displays the sign māori gloss" do
    expect(subject).to have_content sign.maori
  end

  it "displays the sign secondary gloss" do
    expect(subject).to have_content sign.secondary
  end

  it "has the expected page title" do
    expect(page).to have_title "#{sign.word} – NZSL Share"
  end

  context "user not signed in" do
    before do
      auth.sign_out
      sign_page.start(sign)
    end

    context "sign is published" do
      let(:sign) { FactoryBot.create(:sign, :published) }

      it "displays the sign word" do
        expect(subject).to have_selector "h2", text: sign.word
      end
    end

    it "doesn't display the sign" do
      expect(page).not_to have_content sign.word
    end
  end

  context "moderator is signed in" do
    let(:user) { FactoryBot.create(:user, :moderator) }

    it "displays the sign word" do
      expect(subject).to have_selector "h2", text: sign.word
    end
  end

  describe "sign video" do
    subject { sign_page.video_player }
    context "sign is unprocessed" do
      let(:sign) { FactoryBot.create(:sign, :unprocessed) }
      it { expect(subject[:poster]).to match(/processing-[a-f0-9]+.svg/) }
    end

    context "sign has thumbnails processed, but not videos" do
      let(:sign) { FactoryBot.create(:sign, :unprocessed, :processed_thumbnails) }
      it { expect(subject[:poster]).to match(%r{/rails/active_storage}) }
    end

    context "sign has videos" do
      let(:sign) { FactoryBot.create(:sign, :processed_videos) }
      # 1080p, 720p, 360p
      it { expect(subject).to have_selector("source[src^='/signs/#{sign.id}/videos']", count: 3) }
    end
  end

  describe "sign controls" do
    context "owned by the current user" do
      let(:user) { sign.contributor }
      it { within("#sign_overview") { expect(sign_page).to have_link "Edit" } }
      it { within("#sign_overview") { expect(sign_page).to have_content "private" } }
      it "shows the personal description and edit instructions on hover" do
        within("#sign_overview") do
          title = find("#sign_status")["title"]
          assert_equal(
            title, I18n.t!("signs.personal.description") + " " + I18n.t!("signs.personal.edit_status_instructions")
          )
        end
      end

      context "sign has been submitted for publishing" do
        let(:sign) { FactoryBot.create(:sign, :submitted) }
        it { within("#sign_overview") { expect(sign_page).to have_link "Edit" } }
        it { expect(sign_page).to have_content "in progress" }
        it "shows the submitted description on hover" do
          within("#sign_overview") do
            title = find("#sign_status")["title"]
            assert_equal(title.strip!, I18n.t!("signs.submitted.description"))
          end
        end
      end
    end

    context "not logged in" do
      it { expect(sign_page).not_to have_css "#sign_overview" }
    end

    context "not owned by the current user" do
      let(:user) { FactoryBot.create(:user) }
      it { expect(sign_page).not_to have_css "#sign_overview" }
    end
  end

  it "displays the contributor's username" do
    expect(subject).to have_content sign.contributor.username
  end

  it "displays the sign topic" do
    expect(subject).to have_content sign.topic.name
  end

  it "shows a breadcrumb to the sign" do
    subject.breadcrumb { expect(subject).to have_content "Current: #{sign.word}" }
  end

  it "shows a breadcrumb to the topic" do
    subject.breadcrumb { expect(subject).to have_link sign.topic.name }
  end

  it "displays the sign description" do
    sign.update!(description: "Hello, world!")
    visit current_path # Reload
    expect(subject).to have_selector "p", text: "Hello, world!"
  end
end
