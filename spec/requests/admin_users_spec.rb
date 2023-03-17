require "rails_helper"

RSpec.describe "/admin/users", type: :request do
  describe "DELETE destroy" do
    it "destroys the user via DeleteUserJob" do
      allow(DeleteUserJob).to receive(:perform_now)
      user = FactoryBot.create(:user)
      sign_in FactoryBot.build(:user, administrator: true)
      delete admin_user_path(user)
      expect(DeleteUserJob).to have_received(:perform_now).with(user)
    end

    it "destroys unconfirmed users" do
      allow(DeleteUserJob).to receive(:perform_now)
      user = FactoryBot.create(:user, :unconfirmed)
      sign_in FactoryBot.build(:user, administrator: true)
      delete admin_user_path(user)
      expect(DeleteUserJob).to have_received(:perform_now).with(user)
    end

    it "redirects with a success message" do
      user = FactoryBot.create(:user)
      sign_in FactoryBot.build(:user, administrator: true)
      delete admin_user_path(user)
      expect(response).to redirect_to admin_users_path
      expect(flash[:notice]).to eq "User was successfully destroyed."
    end
  end
end
