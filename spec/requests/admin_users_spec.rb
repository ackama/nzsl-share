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
  end
end
