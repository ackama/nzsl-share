require "rails_helper"

RSpec.describe "sign_requests/index.html.erb", type: :view do
  before { render }

  it "contains a link to the sign requests facebook group" do
    expect(rendered).to have_link("Go to Facebook", href: "https://www.facebook.com/groups/213136893357675/")
  end
end
