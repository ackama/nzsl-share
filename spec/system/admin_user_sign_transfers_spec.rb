require "rails_helper"

RSpec.describe "Admin: User Sign Transfers", type: :system do
  let!(:administrator) { FactoryBot.create(:user, :administrator) }
  let!(:old_owner) { FactoryBot.create(:user) }
  let!(:new_owner) { FactoryBot.create(:user) }
  let!(:signs) { FactoryBot.create_list(:sign, 3, contributor: old_owner) }

  before do
    sign_in administrator
    visit admin_user_path(old_owner)
  end

  it "the administrator can transfer ownership of a user's signs to another user" do
    # Visit page via link
    click_link I18n.t("admin.user_sign_transfers.new.link_text")

    # Select the user to transfer the signs to and initiate the process
    select new_owner.username, from: "New owner"
    click_button "Transfer sign ownership"

    # Check path and flash message
    expect(current_path).to eq(admin_user_path(old_owner))
    expect(page.body).to have_content(I18n.t("admin.user_sign_transfers.create.success"))

    # Check that ownership of the signs has changed
    signs.each do |sign|
      sign.reload
      expect(sign.contributor).to eq(new_owner)
    end
  end
end
