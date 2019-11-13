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
            title, I18n.t!("signs.personal.description") + " " + I18n.t!("signs.personal.status_notes")
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

        it "user can cancel publication", uses_javascript: true do
          click_on "Sign Options"
          click_on "Cancel (don’t show to public)"
          alert = page.driver.browser.switch_to.alert
          expect(alert.text).to eq I18n.t!("sign_publish.destroy.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_publish.destroy.success")
          sign.reload
          expect(sign.personal?).to eq true
        end
      end

      context "sign has been published" do
        let(:sign) { FactoryBot.create(:sign, :published) }
        subject(:sign_page) { SignPage.new }

        it { within("#sign_overview") { expect(sign_page).not_to have_link "Edit" } }
        it { expect(sign_page).to have_content "public" }

        it "shows the published description on hover" do
          within("#sign_overview") do
            title = find("#sign_status")["title"]
            assert_equal(title.strip!, I18n.t!("signs.published.description"))
          end
        end

        it "user can request unpublish", uses_javascript: true do
          click_on "Sign Options"
          click_on "Ask to be private"
          alert = page.driver.browser.switch_to.alert
          expect(alert.text).to eq I18n.t!("sign_request_publish.destroy.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_request_publish.destroy.success")
          sign.reload
          expect(sign.unpublish_requested?).to eq true
        end
      end

      context "user has asked for sign to be unpublished" do
        let(:sign) { FactoryBot.create(:sign, :unpublish_requested) }

        it { within("#sign_overview") { expect(sign_page).not_to have_link "Edit" } }
        it { expect(sign_page).to have_content "(asked on #{sign.requested_unpublish_at.strftime("%d %b %Y")})" }
        it { expect(sign_page).to have_content "asked to unpublish" }

        it "shows the requested unpublish description on hover" do
          within("#sign_overview") do
            title = find("#sign_status")["title"]
            assert_equal(title.strip!, I18n.t!("signs.unpublish_requested.description"))
          end
        end

        it "user can cancel request to make sign private", uses_javascript: true do
          click_on "Sign Options"
          click_on "Keep sign public"
          alert = page.driver.browser.switch_to.alert
          expect(alert.text).to eq I18n.t!("sign_publish.create.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_publish.create.success")
          sign.reload
          expect(sign.published?).to eq true
        end
      end
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
