require "rails_helper"

RSpec.describe "signs/edit.html.erb", type: :view do
  let(:sign) { FactoryBot.create(:sign, contributor: user) }
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_authorization
    assign(:sign, sign)
    allow(view).to receive(:current_user).and_return(user)
    render
  end

  it "shows the option to change the video" do
    expect(rendered).to have_button("Change video")
  end

  context "if the sign has been published" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }

    it "doesn't show the option to change the video" do
      expect(rendered).not_to have_button("Change video")
    end
  end
end
