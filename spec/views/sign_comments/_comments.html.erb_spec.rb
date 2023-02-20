require "rails_helper"

RSpec.describe "sign_comments/_comments.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }
  let(:new_comment) { SignComment.new(sign:) }
  let!(:comments) { FactoryBot.create_list(:sign_comment, 3, sign:, user:) }
  subject { rendered }

  before do
    view.class.include Pundit
    sign_in user
    params[:controller] = :signs
    params[:action] = :show
    params[:id] = sign.id

    assign(:sign, sign)
    assign(:new_comment, new_comment)
    assign_comments(comments)
  end

  context "on a public sign" do
    before { render }
    it { is_expected.to have_select("comments_in_folder", with_options: ["Public"]) }
    it { is_expected.to have_selector(".sign-comment", count: comments.size) }

    it "displays a comment with a link" do
      comment_text = "check this out https://rubygems.org"
      comments.first.update!(comment: comment_text)
      assign_comments([comments.first])
      render

      expect(rendered).to have_selector(".sign-comments__comment", text: comment_text)
      expect(rendered).to have_link "https://rubygems.org"
    end

    it "escapes HTML" do
      comment_text = "check <a href='http://rubygems.org/'>ruby gems</a>"
      comments.first.update!(comment: comment_text)
      assign_comments([comments.first])
      render

      expect(rendered).to have_no_selector ".sign-comments__comment", text: comment_text
      expect(rendered).to have_selector ".sign-comments__comment", text: "check ruby gems"
      expect(rendered).to have_no_link(href: "https://rubygems.org/")
    end

    context "non-approved user" do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to have_no_field("Write your text comment") }
    end
  end

  private

  def assign_comments(comments)
    assign(:comments, SignComment.where(id: comments).page(params[:comment_page]))
  end
end
