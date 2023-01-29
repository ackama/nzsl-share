require "rails_helper"

RSpec.describe "admin/user_sign_transfers/new.html.erb", type: :view do
  let!(:user) { FactoryBot.create(:user, :administrator) }
  let!(:old_owner) { FactoryBot.create(:user) }
  let!(:new_owners) do
    owners = FactoryBot.create_list(:user, 3)
    owners << user

    owners
  end
  let!(:system_user) { SystemUser.find }
  subject { rendered }

  before do
    view.class.include Pundit
    sign_in user

    assign(:old_owner, old_owner)
    render
  end

  it "displays the old owner who's signs are being transferred" do
    expect(subject).to have_content("Old owner #{old_owner.username}", normalize_ws: true)
  end

  it "has the expected users in the new user dropdown" do
    expect(subject).to have_select("New owner", options: new_owners.pluck(:username))
    expect(subject).not_to have_select("New owner", with_options: [old_owner.username])
    expect(subject).not_to have_select("New owner", with_options: [system_user.username])
  end
end
