require "rails_helper"

RSpec.describe "Comment report administration", type: :system do
  include AdministratePageHelpers
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:sign) { FactoryBot.create(:sign, :published) }
  let!(:comment) { FactoryBot.create(:sign_comment, sign:) }
  let!(:comment_report) { FactoryBot.create(:comment_report, comment:) }

  before do
    visit_admin(:comment_reports, admin:)
  end

  it_behaves_like "an Administrate dashboard", except: %i[destroy new edit]

  describe "viewing", uses_javascript: true do
    it "can view a comment report" do
      first_row.click
      expect(page).to have_current_path("/admin/comment_reports/#{comment_report.id}")
      expect(page).to have_content comment.comment
      expect(page).to have_content comment_report.user.email
      expect(page).to have_link "Ignore report"
      expect(page).to have_link "Remove comment"
    end
  end

  describe "resolving", uses_javascript: true do
    before { first_row.click }

    it "shows a confirmation alert before ignoring" do
      click_link "Ignore report"
      confirmation = page.driver.browser.switch_to.alert
      expect(confirmation.text).to eq I18n.t!("comment_reports.destroy.confirm")
    end

    it "can ignore a report" do
      expect(comment.reports.count).to eq 1
      accept_confirm do
        click_link "Ignore report"
      end
      expect(page).to have_current_path(admin_comment_reports_path)
      expect(comment.reports.count).to eq 0
    end

    it "shows a confirmation alert before removing comment" do
      click_link "Remove comment"
      confirmation = page.driver.browser.switch_to.alert
      expect(confirmation.text).to eq I18n.t!("sign_comments.destroy.confirm")
    end

    it "can remove an inappropriate comment" do
      expect(comment.reports.count).to eq 1

      accept_confirm do
        click_link "Remove comment"
      end
      expect(page).to have_current_path(admin_comment_reports_path)
      expect(comment.reports.count).to eq 0
      expect(sign.sign_comments[0].removed).to be true
      visit sign_path(sign)
      expect(page).to have_content "This comment has been removed"
    end
  end

  describe "removing", uses_javascript: true do
    context "without a comment report" do
      let!(:unreported_comment) { FactoryBot.create(:sign_comment, sign:) }

      it "admin can delete a comment" do
        visit sign_path(sign)

        within(find(".sign-comments__comment", text: unreported_comment.comment).first(:xpath, ".//..")) do
          click_on "Comment Options"
          accept_confirm do
            click_on "Delete"
          end
        end
        expect(page).to have_content "This comment has been removed"
      end
    end
  end
end
