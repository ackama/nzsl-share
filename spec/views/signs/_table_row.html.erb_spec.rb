require "rails_helper"

RSpec.describe "signs/_table_row.html.erb", type: :view do
  let(:sign) { FactoryBot.build_stubbed(:sign, :published) }

  before { stub_authorization }

  it "renders a checkbox for batch selection" do
    rendered = render "signs/table_row", sign: sign
    expect(rendered).to have_field("Add sign to selection", checked: false)
  end

  it "checks the batch selection checkbox when an appropriate param is present" do
    params[:sign_ids] = [sign.id]
    rendered = render "signs/table_row", sign: sign
    expect(rendered).to have_field("Add sign to selection", checked: true)
  end
end
