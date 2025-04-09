require "rails_helper"

RSpec.describe Admin::ExportsController, type: :request do
  describe "GET /admin/exports/published_signs" do
    let(:user) { FactoryBot.create(:user, :administrator) }
    let(:get_published_signs_admin_exports_path) { get published_signs_admin_exports_path }
    before { sign_in user }

    it "returns the data directly from the service" do
      service_double = instance_double(PublishedSignsExport, to_csv: "test csv contents")
      allow(PublishedSignsExport).to receive(:new).and_return(service_double)
      get_published_signs_admin_exports_path

      expect(response.body).to eq "test csv contents"
    end

    it "returns the filename" do
      get_published_signs_admin_exports_path
      expect(response.headers["Content-Disposition"]).to include 'filename="published-signs.csv"'
    end

    it "returns the content disposition to download the file" do
      get_published_signs_admin_exports_path
      expect(response.headers["Content-Disposition"]).to start_with "attachment"
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        get_published_signs_admin_exports_path

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include "NotAuthorizedError"
      end
    end
  end

  describe "GET /admin/exports/users" do
    let(:user) { FactoryBot.create(:user, :administrator) }
    let(:get_users_admin_exports_path) { get users_admin_exports_path }
    before { sign_in user }

    it "returns the data directly from the service" do
      service_double = instance_double(UsersExport, to_csv: "test csv contents")
      allow(UsersExport).to receive(:new).and_return(service_double)
      get_users_admin_exports_path

      expect(response.body).to eq "test csv contents"
    end

    it "returns the filename" do
      get_users_admin_exports_path
      expect(response.headers["Content-Disposition"]).to include 'filename="users.csv"'
    end

    it "returns the content disposition to download the file" do
      get_users_admin_exports_path
      expect(response.headers["Content-Disposition"]).to start_with "attachment"
    end

    context "not an admin" do
      let(:user) { FactoryBot.create(:user) }

      it "is unauthorised" do
        get_users_admin_exports_path

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include "NotAuthorizedError"
      end
    end
  end
end
