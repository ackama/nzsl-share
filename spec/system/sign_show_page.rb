require "rails_helper"

RSpec.describe "Sign show page", system: true do
  let(:user) { nil }
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
      it { within("#sign_overview") { expect(sign_page).to have_link "ask to make public" } }
      it {
        within("#sign_overview") do
          title = find("#sign_status")["title"]
          assert_equal(title, "'private' means that you have not asked for the sign to be made public.")
        end
      }

      context "sign has been submitted for publishing" do
        let(:sign) { FactoryBot.create(:sign, :submitted) }
        it { within("#sign_overview") { expect(sign_page).to have_link "Edit" } }
        it { expect(sign_page).to have_content "in progress" }
        it { within("#sign_overview") { expect(sign_page).not_to have_content "ask to make public" } }
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
