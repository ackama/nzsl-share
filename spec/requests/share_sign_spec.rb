# frozen_string_literal: true

require "rails_helper"

RSpec.describe "share_sign", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:allowed_sign) { FactoryBot.create(:sign) }

  let(:create) do
    ->(id) { post "/signs/#{id}/share" }
  end

  let(:destroy) do
    ->(sign_id, id) { delete "/signs/#{sign_id}/share/#{id}" }
  end

  let(:show) do
    ->(sign_id, id) { get "/signs/#{sign_id}/share/#{id}" }
  end

  let(:invalid_show) do
    ->(sign_id, id) { get "/signs/#{sign_id}/share/#{id}" }
  end

  describe "#share" do
    context "token" do
      before(:each) do
        sign_in user
        allowed_sign.contributor = user
        allowed_sign.save
      end

      it "creates" do
        expect(allowed_sign.share_token).to be_nil
        create.call(allowed_sign.id)
        expect(allowed_sign.reload.share_token).to be_truthy
        expect(allowed_sign.share_token
          .match(/\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\Z/i).present?).to be true
        expect(response).to redirect_to "#{signs_path}/#{allowed_sign.id}"
      end

      it "destroys" do
        expect(allowed_sign.share_token).to be_nil
        create.call(allowed_sign.id)
        expect(allowed_sign.reload.share_token).to be_truthy
        destroy.call(allowed_sign.id, allowed_sign.share_token)
        expect(allowed_sign.reload.share_token).to be_nil
        expect(response).to redirect_to "#{signs_path}/#{allowed_sign.id}"
      end

      it "shows" do
        create.call(allowed_sign.id)
        expect(allowed_sign.reload.share_token).to be_truthy
        show.call(allowed_sign.id, allowed_sign.share_token)
        expect(response).to be_successful
      end
    end

    context "unauthenticated user" do
      before(:each) do
        sign_in user

        allowed_sign.contributor = user
        allowed_sign.save
        create.call(allowed_sign.id)
        allowed_sign.reload.share_token

        sign_out user
      end

      it "shows" do
        show.call(allowed_sign.id, allowed_sign.share_token)
        expect(allowed_sign.share_token).to be_truthy
        expect(response).to be_successful
      end
    end

    context "unauthenticated user" do
      before(:each) do
        sign_in user

        allowed_sign.contributor = user
        allowed_sign.save
        create.call(allowed_sign.id)
        allowed_sign.reload.share_token

        sign_out user
      end

      it "shows" do
        show.call(allowed_sign.id, allowed_sign.share_token)
        expect(allowed_sign.share_token).to be_truthy
        expect(response).to be_successful
      end
    end

    context "invalid id and share token" do
      before(:each) do
        sign_in user
        allowed_sign.contributor = user
        allowed_sign.save
      end

      it "returns 404 Not Found" do
        invalid_show.call("soup", "pretzel")

        expect(response).to have_http_status(404)
        expect(response.body).to include "RecordNotFound"
      end
    end
  end
end
