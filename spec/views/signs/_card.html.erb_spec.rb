require "rails_helper"

RSpec.describe "signs/_card.html.erb", type: :view do
  let(:user) { FactoryBot.build(:user) }
  let(:sign) { FactoryBot.build_stubbed(:sign, :published, contributor: user) }
  let(:presenter) { SignPresenter.new(sign, ApplicationController.new) }
  subject(:rendered) { render "signs/card", sign: sign }

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
    sign_in user
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

  it "shows the folder button"
  it "shows the folder button in an active state if the sign is already in a user folder"
end
