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
