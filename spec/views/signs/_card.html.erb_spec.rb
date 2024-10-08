require "rails_helper"

RSpec.describe "signs/_card.html.erb", type: :view do
  let(:user) { FactoryBot.build(:user) }
  let(:sign) { FactoryBot.build_stubbed(:sign, :published, contributor: user) }
  let(:presenter) { SignPresenter.new(sign, view) }
  subject(:rendered) { render "signs/card", sign: }

  before { stub_authorization }

  it "shows the title" do
    expect(rendered).to have_selector ".sign-card__title", text: sign.word
  end

  it "shows the contributor's username" do
    expect(rendered).to have_content sign.contributor.username
  end

  it "contributor's username links to their profile" do
    expect(rendered).to have_link(sign.contributor.username, href: user_path(sign.contributor.username))
  end

  it "shows a formatted date" do
    expect(rendered).to have_content presenter.friendly_date
  end

  it "shows the sign status if the user can access the record" do
    expect(rendered).to have_content "Public"
    title = Capybara.string(rendered).find("#sign_status")["title"]
    expect(title).to eq I18n.t!("signs.published.description")
  end

  it "does not show the sign status if they cannot overview the record", signed_out: true do
    stub_authorization(any_args, overview?: false)
    expect(rendered).to have_no_content "Public"
  end

  it "shows the embedded media" do
    expect(rendered).to have_selector ".sign-card__media > .video-wrapper > video.video"
  end

  it "shows the Māori gloss" do
    expect(rendered).to have_selector ".sign-card__supplementary-titles__maori", text: sign.maori
  end

  it "shows the secondary gloss" do
    expect(rendered).to have_selector ".sign-card__supplementary-titles__secondary", text: sign.secondary
  end

  it "shows a button to Agree with the sign" do
    expect(rendered).to have_link "Agree"
  end

  it "shows a button to Disagree with the sign" do
    expect(rendered).to have_link "Disagree"
  end

  it "shows the folder button when signed in" do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    expect(rendered).to have_button(class: "sign-card__folders__button")
    expect(rendered).to have_selector(".sign-card__folders__button > svg > title", text: "Folders")
  end

  it "shows a fake folder button to the sign in page when signed out" do
    sign_out :user
    expect(rendered).to have_link("Folders", href: new_user_session_path)
  end

  it "shows the folder button in an active state if the sign is already in a user folder" do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:present).with(sign).and_return(presenter)
    expect(presenter).to receive(:available_folders).at_least(1).times.and_return([Folder.new])

    expect(rendered).to have_button(
      class: %w[sign-card__folders__button sign-card__folders__button--in-folder])
    expect(rendered).to have_selector(
      ".sign-card__folders__button > svg > title",
      text: "Folders")
  end

  it "shows a count of comments for the sign that the user can access" do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:present).with(sign).and_return(presenter)
    expect(presenter).to receive(:comments_count).and_return(10)
    expect(rendered).to have_selector(".sign-control--comments", text: "Comments\n\n\n  10")
  end

  it "shows an indicator on the comment icon when the user has unread comments" do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:present).with(sign).and_return(presenter)
    expect(presenter).to receive(:comments_count).and_return(1)
    expect(presenter).to receive(:unread_comments?).and_return(true)

    expect(rendered).to have_selector(
      ".sign-control--comments--unread",
      text: "Comments\n\n\n  1")
  end

  it "does not show the comment count when the user is not signed in" do
    expect(rendered).not_to have_selector(".sign-control--comments")
  end
end
