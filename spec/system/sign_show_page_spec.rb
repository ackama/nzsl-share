require "rails_helper"

RSpec.describe "Sign show page", system: true do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, contributor: user) }
  subject(:sign_page) { SignPage.new }

  before do
    sign_in user if user
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

  it "contributor username links to profile page" do
    within ".sign-card__subtitle" do
      click_on sign.contributor.username
      expect(page).to have_current_path(user_path(sign.contributor.username))
    end
  end

  it "displays the sign status" do
    sign_card = page.find("#sign_status", match: :prefer_exact)
    expect(sign_card).to be_present
    expect(sign_card.text).to eq "Private"
  end

  it "has the expected page title" do
    expect(page).to have_title "#{sign.word} – NZSL Share"
  end

  it "has the expected share link" do
    expect(page).to have_link(nil, href: "/signs/#{sign.id}/share") # be explicit page has another 'share' context
  end

  it "has the expected 'Add to Folder' button" do
    expect(page).to have_link "Add to Folder"
  end

  context "share public sign with anonymous user" do
    let(:sign) { FactoryBot.create(:sign, :published) }

    before do
      sign.update(share_token: sign.share_token || SecureRandom.uuid)
      sign_out :user
      visit sign_share_url(sign, sign.share_token)
    end

    it "does not have the sign share link" do
      expect(page).to have_no_link(nil, href: "/signs/#{sign.id}/share") # be explicit page has another 'share' context
    end

    it "does not have the sign status" do
      expect(page).to have_no_selector("#sign_status")
    end

    it "has the expected link 'Add to Folder'" do
      expect(page).to have_link "Add to Folder"
    end

    it "redirects to login when 'Add to Folder' link clicked" do
      click_link("Add to Folder")
      expect(page.current_path).to eq new_user_session_path
    end
  end

  context "share private sign with anonymous user" do
    let(:sign) { FactoryBot.create(:sign, :personal, contributor: user) }

    before do
      sign.update(share_token: sign.share_token || SecureRandom.uuid)
      sign_out :user
      visit sign_share_url(sign, sign.share_token)
    end

    it "does not have the sign share link" do
      expect(page).to have_no_link(nil, href: "/signs/#{sign.id}/share") # be explicit page has another 'share' context
    end

    it "does not have the sign status" do
      expect(page).to have_no_selector("#sign_status")
    end

    it "does not have the expected link 'Add to Folder'" do
      expect(page).to have_no_link "Add to Folder"
    end
  end

  context "user not signed in" do
    before do
      sign_out :user
      sign_page.start(sign)
    end

    context "sign is published" do
      let(:sign) { FactoryBot.create(:sign, :published) }

      it "displays the sign word" do
        expect(subject).to have_selector "h2", text: sign.word
      end
    end
  end

  context "moderator is signed in" do
    let(:sign) { FactoryBot.create(:sign, :published) }
    let(:user) { FactoryBot.create(:user, :moderator) }

    it "displays the sign word" do
      expect(subject).to have_selector "h2", text: sign.word
    end
  end

  describe "sign video" do
    subject { sign_page.video_player }
    context "sign is unprocessed" do
      let(:sign) { FactoryBot.create(:sign, :unprocessed, contributor: user) }
      it { expect(subject[:poster]).to match(/processing-[a-f0-9]+.svg/) }
    end

    context "sign has thumbnails processed, but not videos" do
      let(:sign) { FactoryBot.create(:sign, :unprocessed, :processed_thumbnails, contributor: user) }
      it { expect(subject[:poster]).to match(%r{/rails/active_storage}) }
    end

    context "sign has videos" do
      let(:sign) { FactoryBot.create(:sign, :processed_videos, contributor: user) }
      # 1080p, 720p, 360p
      it { expect(subject).to have_selector("source[src^='/videos']", count: 3) }
    end
  end

  describe "sign controls" do
    context "moderator is signed in" do
      let(:user) { FactoryBot.create(:user, :moderator) }

      context "sign has been submitted for publishing" do
        let(:sign) { FactoryBot.create(:sign, :submitted) }

        it "displays the moderator message" do
          within("#sign_overview") do
            expect(sign_page).to have_content I18n.t("sign_workflow.publish.confirm")
            expect(sign_page).to have_content "A user has made a request. This sign is currently"
          end
        end

        it "allows the moderator to publish the sign", uses_javascript: true do
          within("#sign_overview") { expect(sign_page).to have_link "Edit" }

          my_link = find(:xpath, "//a[contains(@href,'signs/#{sign.id}/publish')]")

          my_link.click
          alert = page.driver.browser.switch_to.alert

          expect(alert.text).to eq I18n.t!("sign_workflow.publish.confirm")
          alert.accept
          expect(subject).to have_content I18n.t!("sign_workflow.publish.success")
          sign.reload
          expect(sign.published?).to eq true
        end

        it "allows the moderator to decline the sign", uses_javascript: true do
          within("#sign_overview") { expect(sign_page).to have_link "Edit" }

          my_link = find(:xpath, "//a[contains(@href,'signs/#{sign.id}/decline')]")

          my_link.click
          alert = page.driver.browser.switch_to.alert

          expect(alert.text).to eq I18n.t!("sign_workflow.decline.confirm")
          alert.accept
          expect(subject).to have_content I18n.t!("sign_workflow.decline.success")
          sign.reload
          expect(sign.declined?).to eq true
        end
      end

      context "sign has been published" do
        let(:sign) { FactoryBot.create(:sign, :published) }

        it "displays the moderator message" do
          within("#sign_overview") do
            expect(sign_page).to have_content "you are moderating this sign"
            expect(sign_page).to have_no_content "A user has made a request. This sign is currently:"
          end
        end

        it "allows the moderator to manage the sign" do
          within("#sign_overview") { expect(sign_page).to have_link "Edit" }
        end
      end

      context "sign has been requested for unpublishing" do
        let(:sign) { FactoryBot.create(:sign, :unpublish_requested) }

        it "displays the moderator message" do
          within("#sign_overview") do
            expect(sign_page).to have_content I18n.t("sign_workflow.unpublish.confirm")
            expect(sign_page).to have_content "A user has made a request. This sign is currently:"
          end
        end

        it "allows the moderator to manage the sign" do
          within("#sign_overview") { expect(sign_page).to have_link "Edit" }
        end
      end
    end

    context "owned by the current user" do
      it { within("#sign_overview") { expect(sign_page).to have_link "Edit" } }
      it { within("#sign_overview") { expect(sign_page).to have_content "Private" } }
      it { within("#sign_overview") { expect(sign_page).to have_content "you are the creator of this sign" } }

      it "shows the personal description and edit instructions on hover" do
        within("#sign_overview") do
          title = find("#sign_status")["title"]
          assert_equal(
            title, "#{I18n.t!("signs.personal.description")} #{I18n.t!("signs.personal.status_notes")}"
          )
        end
      end

      context "sign has been submitted for publishing" do
        let(:user) { FactoryBot.create(:user, :approved) } # User must be approved to submit/cancel submit
        let(:sign) { FactoryBot.create(:sign, :submitted, contributor: user) }

        it { within("#sign_overview") { expect(sign_page).to have_link "Edit" } }
        it { expect(sign_page).to have_content "In Progress" }

        it "shows the submitted description on hover" do
          within("#sign_overview") do
            title = find("#sign_status")["title"]
            assert_equal(title.strip!, I18n.t!("signs.submitted.description"))
          end
        end

        it "user can cancel publication", uses_javascript: true do
          click_on "Sign Options"

          click_on "Cancel"
          alert = page.driver.browser.switch_to.alert
          expect(alert.text).to eq I18n.t!("sign_workflow.cancel_submit.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_workflow.cancel_submit.success")
          sign.reload
          expect(sign.personal?).to eq true
        end
      end

      context "sign has been published" do
        let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
        subject(:sign_page) { SignPage.new }

        it { within("#sign_overview") { expect(sign_page).to have_no_link "Edit" } }
        it { expect(sign_page).to have_content "Public" }

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
          expect(alert.text).to eq I18n.t!("sign_workflow.request_unpublish.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_workflow.request_unpublish.success")
          sign.reload
          expect(sign.unpublish_requested?).to eq true
        end
      end

      context "user has asked for sign to be unpublished" do
        let(:sign) { FactoryBot.create(:sign, :unpublish_requested, contributor: user) }

        it { within("#sign_overview") { expect(sign_page).to have_no_link "Edit" } }
        it { expect(sign_page).to have_content "(asked on #{sign.requested_unpublish_at.strftime("%d %b %Y")})" }
        it { expect(sign_page).to have_content "Asked to Unpublish" }

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
          expect(alert.text).to eq I18n.t!("sign_workflow.cancel_request_unpublish.confirm")
          alert.accept
          expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
          expect(subject).to have_content I18n.t!("sign_workflow.cancel_request_unpublish.success")
          sign.reload
          expect(sign.published?).to eq true
        end
      end
    end

    context "not owned by the current user" do
      let(:sign) { FactoryBot.create(:sign, :published) }
      let(:user) { FactoryBot.create(:user) }
      it { expect(sign_page).to have_no_css "#sign_overview" }
    end
  end

  context "sign usage examples" do
    let(:sign) { FactoryBot.create(:sign, :with_usage_examples, contributor: user) }

    it "displays the usage example videos" do
      expect(sign_page).to have_content "Usage"
      expect(sign_page).to have_selector ".usage-examples .video", count: sign.usage_examples.size
    end
  end

  context "sign illustrations" do
    let(:sign) { FactoryBot.create(:sign, :with_illustrations, contributor: user) }

    it "displays the illustrations" do
      expect(sign_page).to have_content "Illustration"
      expect(sign_page).to have_selector ".illustrations img", count: sign.illustrations.size
    end
  end

  it "displays the contributor's username" do
    expect(subject).to have_content sign.contributor.username
  end

  it "displays the sign topic" do
    expect(subject).to have_content sign.topics.first.name
  end

  it "shows a breadcrumb to the sign" do
    subject.breadcrumb { expect(subject).to have_content "Current: #{sign.word}" }
  end

  it "shows a breadcrumb to the topic" do
    subject.breadcrumb { expect(subject).to have_link sign.topics.first.name }
  end

  it "displays the sign notes" do
    sign.update!(notes: "Hello, world!")
    visit current_path
    expect(subject).to have_selector "p", text: "Hello, world!"
  end

  shared_examples "sign card voting" do
    it "is able to register an agree" do
      within ".sign-controls" do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__votes--agreed", text: "1"
      end
    end

    it "is able to deregister an agree" do
      within ".sign-controls" do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__votes--agreed", text: "1"
        click_on "Undo agree"
        expect(page).to have_selector ".sign-card__votes--agree", text: "0"
      end
    end

    it "is able to register a disagree" do
      within ".sign-controls" do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
      end
    end

    it "is able to deregister a disagree" do
      within ".sign-controls" do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
        click_on "Undo disagree"
        expect(page).to have_selector ".sign-card__votes--disagree", text: "0"
      end
    end

    it "is able to switch from agree to disagree" do
      within ".sign-controls" do
        click_on "Agree"
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--agree", text: "0"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
      end
    end
  end

  describe "Voting" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
    let(:user) { FactoryBot.create(:user, :approved) }

    context "not an approved user" do
      let(:user) { FactoryBot.create(:user) }
      it { expect(page).to have_no_link "Agree" }
      it { expect(page).to have_selector ".sign-card__votes--agree", text: "0" }
    end

    context "without JS" do
      include_examples "sign card voting"
    end

    context "with JS", uses_javascript: true do
      include_examples "sign card voting"
    end
  end

  it "has the sign metadata for social sharing" do
    expect(subject).to have_css "meta[property='og:site_name'][content='NZSL Share']", visible: false
    expect(subject).to have_css "meta[property='og:title'][content=#{sign.word}]", visible: false
    expect(subject).to have_css "meta[property='og:description'][content=#{sign.secondary}]", visible: false
  end
end
