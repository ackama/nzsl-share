require "rails_helper"

RSpec.describe "signs/table/_controls.html.erb", type: :view do
  before { stub_policy_scope(Topic) }

  it "allows assignment of a topic" do
    rendered = render
    expect(rendered).to have_select("Assign topics", with_options: Topic.pluck(:name))
    expect(rendered).to have_button("Assign")
  end
end
