require "rails_helper"

RSpec.describe "signs/table/_controls.html.erb", type: :view do
  before { stub_policy_scope(Topic) }

  it "allows assignment of a topic" do
    allow(view).to receive(:current_user).and_return(FactoryBot.create(:user))
    rendered = render
    expect(rendered).to have_select("Assign topics", with_options: Topic.pluck(:name))
    expect(rendered).to have_button("Assign")
  end

  it "allows submission of signs" do
    allow(view).to receive(:current_user).and_return(FactoryBot.create(:user, :approved))
    rendered = render
    expect(rendered).to have_button("Submit for publishing")
  end

  it "doesn't show the submit for publishing button if the current user is not approved" do
    allow(view).to receive(:current_user).and_return(FactoryBot.create(:user))
    rendered = render
    expect(rendered).not_to have_button("Submit for publishing")
  end
end
