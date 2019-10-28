require "rails_helper"

RSpec.describe "Sign show page", system: true do
  let(:sign) { FactoryBot.create(:sign) }
  subject(:sign_page) { SignPage.new }

  before { sign_page.start(sign) }

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
