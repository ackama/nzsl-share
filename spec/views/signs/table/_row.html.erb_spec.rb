require "rails_helper"

RSpec.describe "signs/table/_row.html.erb", type: :view do
  let(:user) { FactoryBot.build(:user) }
  let(:sign) { FactoryBot.build_stubbed(:sign, :published, contributor: user, topics: topics) }
  let(:topics) { FactoryBot.build_list(:topic, 3) }
  let(:presenter) { SignPresenter.new(sign, view) }
  subject(:rendered) { render "signs/table/row", sign: sign }

  before { stub_authorization }

  it "shows the title" do
    expect(rendered).to have_selector ".sign-table__title", text: sign.word
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
    title = Capybara.string(rendered).find(".status")["title"]
    expect(title).to eq I18n.t!("signs.published.description")
  end

  it "does not show the sign status if they cannot overview the record", signed_out: true do
    stub_authorization(any_args, overview?: false)
    expect(rendered).to have_no_content "Public"
  end

  it "shows the topics" do
    expect(rendered).to have_selector ".sign-table__subtitle",
                                      text: sign.topics.pluck(:name).join(", ")
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
    expect(rendered).to have_selector(".sign-control--comments", text: "Comments\n\n  10")
  end

  it "shows an indicator on the comment icon when the user has unread comments" do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:present).with(sign).and_return(presenter)
    expect(presenter).to receive(:comments_count).and_return(1)
    expect(presenter).to receive(:unread_comments?).and_return(true)

    expect(rendered).to have_selector(
      ".sign-control--comments--unread",
      text: "Comments\n\n  1")
  end

  it "does not show the comment count when the user is not signed in" do
    expect(rendered).not_to have_selector(".sign-control--comments")
  end

  it "adds a modifier class to the component when the sign has not been user-edited" do
    expect(rendered).to have_selector(".sign-table__row.sign-table__row--unedited")
  end

  it "does not add a modifier class to the component when the sign has been user-edited" do
    sign.last_user_edit_at = Time.zone.now
    expect(rendered).to have_selector(".sign-table__row:not(.sign-table__row--unedited)")
  end

  it "renders a checkbox for batch selection" do
    expect(rendered).to have_field("Add sign to selection", checked: false)
  end

  it "checks the batch selection checkbox when an appropriate param is present" do
    params[:sign_ids] = [sign.to_param]
    rendered = render "signs/table/row", sign: sign
    expect(rendered).to have_field("Add sign to selection", checked: true)
  end
end
