require "rails_helper"

RSpec.describe "Sign commenting" do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
  let(:comments) { [] }
  subject(:sign_page) { SignPage.new }

  before do
    comments
    sign_in user if user
    sign_page.start(sign)
  end

  context "on a public sign" do
    let!(:comments) { FactoryBot.create_list(:sign_comment, 3, sign:, user:) }

    it "can create a new comment", uses_javascript: true do
      comment_text = Faker::Lorem.sentence
      fill_in "Write your text comment", with: "#{comment_text}\n"
      click_button("Post comment")
      expect(page).to have_selector ".sign-comments__comment", text: comment_text
    end

    it "can create a new video comment", uses_javascript: true, upload_mode: :uppy do
      select "NZSL comment"
      within("#new-video-comment") do
        attach_file "files[]", "spec/fixtures/dummy.exe", visible: false, match: :first
        expect(page).to have_content "You can only upload: video/*, application/mp4"
        attach_file "files[]", "spec/fixtures/small.mp4", visible: false, match: :first
        click_on "Upload 1 file"
        expect(page).to have_selector(".sign-comment__video", count: 1)
        fill_in "Write a text translation", with: "Translation test"
        click_on "Update comment"
      end

      expect(page).to have_selector ".sign-comments__comment video", count: 1
      within(all(".sign-comments__comment").last) { expect(page).to have_content("Translation test") }
    end

    it "can drag and drop a new video comment", uses_javascript: true, upload_mode: :uppy do
      select "NZSL comment"
      within("#new-video-comment") do
        find(".uppy-Dashboard").drop("spec/fixtures/small.mp4")
        find(".uppy-Dashboard").drop("spec/fixtures/medium.mp4")
        expect(page).to have_content "You can only upload 1 file"
        click_on "Upload 1 file"
        expect(page).to have_selector(".sign-comment__video", count: 1)
        click_on "Update comment"
      end

      expect(page).to have_selector ".sign-comments__comment video", count: 1
    end

    it "can post a reply text comment", uses_javascript: true do
      page.find(".sign-comments__replies--link", match: :first).click
      fill_in "Write your text comment", match: :first, with: "My reply"
      click_button("Post comment", match: :first)
      expect(page).to have_content "My reply"
    end

    it "can post a reply video comment", uses_javascript: true, upload_mode: :uppy do
      page.find(".sign-comments__replies--link", match: :first).click
      within("[id^='reply_sign_comment']", match: :first) do
        select "NZSL comment"
        attach_file "files[]", "spec/fixtures/small.mp4", visible: false, match: :first
        click_on "Upload 1 file"
        expect(page).to have_selector(".sign-comment__video", count: 1)
        click_on "Update comment"
      end

      expect(page).to have_selector("[id^='sign_comment_'].sign-comments__replies", count: 1)
    end
  end

  context "editing comments" do
    let!(:comment) { FactoryBot.create(:sign_comment, sign:, user:) }

    it "can edit the comment text" do
      visit current_path
      within ".sign-comment__options" do
        click_on "Comment Options"
        click_on "Edit"
      end

      comment_text = "Updated comment text"
      fill_in "Write your text comment", with: comment_text
      click_on "Update comment"
      expect(page).to have_selector ".sign-comments__comment", text: comment_text
    end

    it "can make the comment anonymous" do
      visit current_path
      within ".sign-comment__options" do
        click_on "Comment Options"
        click_on "Edit"
      end

      check "comment anonymously"
      click_on "Update comment"

      expect(page).to have_no_css ".sign-comments__comment__username--link"
    end

    context "a reply" do
      let!(:reply) { FactoryBot.create(:sign_comment, sign:, user:, in_reply_to: comment) }

      it "can edit the comment text" do
        visit current_path
        within "#options_sign_comment_#{reply.id}" do
          click_on "Edit"
        end

        comment_text = "Updated comment text"
        fill_in "Write your text comment", with: comment_text
        click_on "Update comment"
        expect(page).to have_selector ".sign-comments__comment", text: comment_text
      end

      it "can make the comment anonymous" do
        visit current_path
        expect(page).to have_css ".sign-comments__comment__username--link",
                                 text: reply.user.username,
                                 count: 2 # 2 comments by this user

        within "#options_sign_comment_#{reply.id}" do
          click_on "Edit"
        end

        check "comment anonymously"
        click_on "Update comment"

        expect(page).to have_css ".sign-comments__comment__username--link",
                                 text: reply.user.username,
                                 count: 1
      end

      it "retains the parent association" do
        visit current_path
        expect(page).to have_selector ".sign-comments__comment", text: reply.comment

        within("#options_sign_comment_#{reply.id}") { click_on "Edit" }
        click_on "Update comment"
        expect(page).to have_selector ".sign-comments__comment", text: reply.comment

        reply.reload
        expect(reply.in_reply_to).to eq comment
      end
    end

    context "a video comment" do
      let!(:comment) { FactoryBot.create(:sign_comment, :video, sign:, user:) }

      it "can edit the video caption" do
        visit current_path
        within "#options_sign_comment_#{comment.id}" do
          click_on "Edit"
        end

        caption_text = "Updated caption text"
        expect(page).to have_selector ".sign-comment--heading", text: "dummy.mp4"
        fill_in "Write a text translation", with: caption_text
        click_on "Update comment"
        expect(page).to have_selector ".sign-comments__comment", text: caption_text
      end
    end
  end

  context "removing", uses_javascript: true do
    let!(:comment) { FactoryBot.create(:sign_comment, sign:, user:) }

    it "approved user can delete own comment" do
      visit sign_path(sign)
      within ".sign-comment__options" do
        click_on "Comment Options"
        accept_confirm do
          click_on "Delete"
        end
      end
      expect(page).to have_content "This comment has been removed"
    end
  end

  context "when the user is deleted" do
    let(:commenter) { FactoryBot.create(:user) }
    let!(:comment) { FactoryBot.create(:sign_comment, sign:, user: commenter) }

    it "continues to show the comment, but not the user details" do
      commenter.destroy!
      visit sign_path(sign)
      expect(page).to have_no_selector("sign-comments__comment__username--link")
      expect(page).to have_selector ".sign-comments__comment", text: comment.comment
    end
  end

  context "pagination" do
    let!(:comments) { FactoryBot.create_list(:sign_comment, 30, sign:, user:) }

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
    let(:sign) { FactoryBot.create(:sign, contributor: user) }
    let!(:folder) { FactoryBot.create(:folder, user:) }
    let!(:folder_membership) { FactoryBot.create(:folder_membership, sign:, folder:) }
    let!(:comments) { FactoryBot.create_list(:sign_comment, 3, sign:, user:, folder:) }

    before do
      visit current_path
      select folder.title, from: "comments_in_folder"
    end

    it "folder context is selected" do
      expect(page).to have_select("comments_in_folder", selected: [folder.title])
    end

    it "shows the expected number of comments", uses_javascript: true do
      expect(page).to have_selector(".sign-comment", count: comments.size)
    end

    it "posts a new comment", uses_javascript: true do
      comment_text = Faker::Lorem.sentence
      select folder.title, from: "sign_comment_folder"
      fill_in "Write your text comment", with: "#{comment_text}\n"
      click_button("Post comment")
      expect(page).to have_selector ".sign-comments__comment", text: comment_text
      expect(SignComment.order(created_at: :desc).first.folder).to eq folder
    end

    it "posts a new video comment", uses_javascript: true, upload_mode: :uppy do
      select "NZSL comment"
      select folder.title, from: "sign_comment_folder"

      within "#new-video-comment" do
        attach_file "files[]", "spec/fixtures/small.mp4", visible: false, match: :first
        click_on "Upload 1 file"
        expect(page).to have_selector(".sign-comment__video", count: 1)
        click_on "Update comment"
      end

      expect(page).to have_select("sign_comment_folder", selected: [folder.title])
      expect(page).to have_selector ".sign-comments__comment video", count: 1
    end

    it "cannot report comments", uses_javascript: true do
      within ".sign-comment__options", match: :first do
        click_on "Comment Options"
        expect(page).to have_no_link "Flag as inappropriate"
      end
    end

    context "non-approved user", uses_javascript: true do
      let(:user) { FactoryBot.create(:user) }
      let(:sign) { FactoryBot.create(:sign, :published) }

      it "cannot comment publicly" do
        select "Public", from: "comments_in_folder"
        expect(page).to have_no_field "Write your text comment"
        expect(page).to have_content "Only approved users can comment on public signs."
      end
    end
  end

  context "reporting" do
    let!(:comment) { FactoryBot.create(:sign_comment, sign:, user: FactoryBot.create(:user)) }

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
      FactoryBot.create(:comment_report, comment:, user:)
      visit current_path

      within ".sign-comment__options" do
        click_on "Comment Options"
        expect(page).to have_no_link "Flag as inappropriate"
      end
    end

    it "can report a comment that has already been reported by a different user" do
      FactoryBot.create(:comment_report, comment:, user: FactoryBot.create(:user))
      visit current_path

      within ".sign-comment__options" do
        click_on "Comment Options"
        expect(page).to have_link "Flag as inappropriate"
      end
    end

    context "a comment authored by the current user" do
      let!(:comment) { FactoryBot.create(:sign_comment, sign:, user:) }
      it "cannot report own comment" do
        visit current_path

        within ".sign-comment__options" do
          click_on "Comment Options"
          expect(page).to have_no_link "Flag as inappropriate"
        end
      end
    end
  end
end
