require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "Authorization errors" do
    controller do
      def index
        fail Pundit::NotAuthorizedError
      end
    end

    subject { get :index }

    it "adds a flash message to the response informing the user of the failure" do
      subject
      expect(flash[:alert]).to eq I18n.t!("application.unauthorized")
    end

    it "redirects back to the referer" do
      request.env["HTTP_REFERER"] = new_sign_path
      expect(subject).to redirect_to new_sign_path
    end

    it "redirects to root when there is no referer" do
      expect(subject).to redirect_to root_path
    end
  end
end
