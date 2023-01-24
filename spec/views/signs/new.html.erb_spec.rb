require "rails_helper"

RSpec.describe "signs/new.html.erb", type: :view do
  let(:sign) { Sign.new }

  before do
    assign(:sign, sign)
    render
  end

  it "shows the file upload area", upload_mode: :legacy do
    expect(rendered).to have_selector(".file-upload[data-file-upload-controller='sign[video]']")
  end

  it "shows the multiple file upload area", upload_mode: :uppy do
    expect(rendered).to have_selector("[data-controller='file-upload']")
  end
end
