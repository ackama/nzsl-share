require "rails_helper"

RSpec.describe "home/index.html.erb", type: :view do
  before { render }

  it "contains a link to the sign requests page" do
    expect(rendered).to have_link("Request sign", href: sign_requests_path)
  end
end
