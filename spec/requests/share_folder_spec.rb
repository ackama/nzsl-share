# frozen_string_literal: true

require "rails_helper"

RSpec.describe "share_folder", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:allowed_folder) { FactoryBot.create(:folder) }

  let(:create) do
    ->(id) { post "/folders/#{id}/share" }
  end

  let(:destroy) do
    ->(folder_id, id) { delete "/folders/#{folder_id}/share/#{id}" }
  end

  let(:show) do
    ->(folder_id, id) { get "/folders/#{folder_id}/share/#{id}" }
  end

  let(:invalid_show) do
    ->(folder_id, id) { get "/folders/#{folder_id}/share/#{id}" }
  end

  describe "#share" do
    context "token" do
      before(:each) do
        sign_in user
        allowed_folder.user = user
        allowed_folder.save
      end

      it "creates" do
        expect(allowed_folder.share_token).to be_nil
        create.call(allowed_folder.id)
        expect(allowed_folder.reload.share_token).to be_truthy
        expect(response).to redirect_to folders_path
        expect(allowed_folder.share_token
          .match(/\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\Z/i).present?).to be true
      end

      it "destroys" do
        expect(allowed_folder.share_token).to be_nil
        create.call(allowed_folder.id)
        expect(allowed_folder.reload.share_token).to be_truthy
        destroy.call(allowed_folder.id, allowed_folder.share_token)
        expect(allowed_folder.reload.share_token).to be_nil
        expect(response).to redirect_to folders_path
      end

      it "shows" do
        create.call(allowed_folder.id)
        expect(allowed_folder.reload.share_token).to be_truthy
        show.call(allowed_folder.id, allowed_folder.share_token)
        expect(allowed_folder.reload.share_token).to be_truthy
        expect(response).to be_successful
      end
    end

    context "invalid id and share token" do
      before(:each) do
        sign_in user
        allowed_folder.user = user
        allowed_folder.save
      end

      it "raises an exception" do
        expect { invalid_show.call("soup", "pretzel") }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
