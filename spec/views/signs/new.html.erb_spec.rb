require "rails_helper"

RSpec.describe "signs/new.html.erb", type: :view do
  let(:sign) { Sign.new }

  before do
    assign(:sign, sign)
    allow(view).to receive(:current_user).and_return(User.new)
    render
  end

  it "shows the file upload area", upload_mode: :legacy do
    expect(rendered).to have_selector(".file-upload[data-file-upload-controller='sign[video]']")
  end

  it "shows the multiple file upload area", upload_mode: :uppy do
    expect(rendered).to have_selector("[data-controller='create-sign']")
  end

  it "passes the contribution limit to the create sign process", upload_mode: :uppy do
    view.current_user.contribution_limit = 10
    view.current_user.batch_sign_contributions_permitted = true
    allow(view.current_user.signs).to receive(:count).and_return(5)
    rendered = render
    expect(rendered).to have_selector("[data-create-sign-contribution-limit-value='5']")
  end

  it "limits the upload to a single file unless the user has batch uploads enabled", upload_mode: :uppy do
    view.current_user.contribution_limit = 10
    view.current_user.batch_sign_contributions_permitted = false
    rendered = render
    expect(rendered).to have_selector("[data-create-sign-contribution-limit-value='1']")
  end
end
