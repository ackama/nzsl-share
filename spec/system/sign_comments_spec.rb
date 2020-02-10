require "rails_helper"

RSpec.describe "Sign commenting" do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, contributor: user) }
  let(:auth) { AuthenticateFeature.new(user) }
  subject(:sign_page) { SignPage.new }

  before do
    auth.sign_in if user
    sign_page.start(sign)
  end

  context "public sign comments" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
    let!(:comments) { FactoryBot.create_list(:sign_comment, 10, sign: sign, user: user) }

    it "shows public comments" do
      expect(page).to have_select("comments_in_folder", with_options: ["Public"])
    end

    it "shows the expected number of comments" do
      visit current_path
      expect(page).to have_selector(".sign-comment", count: comments.size)
    end

    it "posts a new comment", uses_javascript: true do
      comment_text = Faker::Lorem.sentence
      fill_in "Write your text comment", with: "#{comment_text}\n"
      click_button("Post comment")
      expect(page).to have_selector ".sign-comments__comment", text: comment_text
    end
  end

  context "pagination" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
    let!(:comments) { FactoryBot.create_list(:sign_comment, 30, sign: sign, user: user) }

    it "shows older comments without JS" do
      expected_comments = comments.sort_by(&:created_at)[10...20].map(&:comment)
      visit current_path
      click_on "Show older comments"
      actual_comments = page.all(".sign-comments__comment .cell.auto:last").map(&:text)
      expect(actual_comments).to match_array expected_comments
    end

    it "shows newer comments without JS" do
      expected_comments = comments.sort_by(&:created_at)[20...30].map(&:comment)
      visit current_path
      click_on "Show older comments"
      click_on "Show newer comments"
      actual_comments = page.all(".sign-comments__comment .cell.auto:last").map(&:text)
      expect(actual_comments).to match_array expected_comments
    end

    it "shows older comments with JS", uses_javascript: true do
      visit current_path
      sorted_comments = comments.sort_by(&:created_at)
      first_set = sorted_comments[20...30].map(&:comment)
      second_set = sorted_comments[10...20].map(&:comment)

      actual_comments = page.all(".sign-comments__comment .cell.auto:last-child").map(&:text)
      expect(actual_comments).to match_array(first_set)

      click_on "Show older comments"

      expect(page).to have_selector(".sign-comment", count: 20)
      actual_comments = page.all(".sign-comments__comment .cell.auto:last-child").map(&:text)
      expect(actual_comments).to match_array(second_set + first_set)
    end
  end

  context "folder comments" do
    let!(:folder) { FactoryBot.create(:folder, user: user) }
    let!(:folder_membership) { FactoryBot.create(:folder_membership, sign: sign, folder: folder) }
    let!(:comments) { FactoryBot.create_list(:sign_comment, 10, sign: sign, user: user, folder: folder) }

    before do
      visit current_path
      select folder.title, from: "comments_in_folder"
    end

    it "does not show public comments" do
      expect(page).to have_select("comments_in_folder", selected: [folder.title])
    end

    it "shows the expected number of comments", uses_javascript: true do
      select folder.title, from: "comments_in_folder"
      expect(page).to have_selector(".sign-comment", count: comments.size)
    end

    xit "posts a new comment", uses_javascript: true do
      comment_text = Faker::Lorem.sentence
      select folder.title, from: "sign_comment_folder"
      fill_in "Write your text comment", with: "#{comment_text}\n"
      click_button("Post comment")
      expect(page).to have_selector ".sign-comments__comment", text: comment_text
      expect(SignComment.order(created_at: :desc).first.folder).to eq folder
    end
  end

  context "reporting" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
    let!(:comment) { FactoryBot.create(:sign_comment, sign: sign, user: user) }

    it "reports a comment" do
      visit current_path
      within ".sign-comment__options" do
        click_on "Comment Options"
        click_on "Flag as inappropriate"
      end

      expect(page).to have_content I18n.t!("comment_reports.create.success")
      expect(comment.reports.size).to eq 1
    end

    it "cannot report a comment that has already been reported by this user" do
      FactoryBot.create(:comment_report, comment: comment, user: user)
      visit current_path

      within ".sign-comment__options" do
        click_on "Comment Options"
        expect(page).to have_no_link "Flag as inappropriate"
      end
    end

    it "can report a comment that has already been reported by a different user" do
      FactoryBot.create(:comment_report, comment: comment, user: FactoryBot.create(:user))
      visit current_path

      within ".sign-comment__options" do
        click_on "Comment Options"
        expect(page).to have_link "Flag as inappropriate"
      end
    end
  end
end
