# frozen_string_literal: true

require "rails_helper"

RSpec.describe "share", type: :request do
  let(:user) { FactoryBot.create(:user) }

  let(:share_with_patch) do
    ->(id) { patch "/folders/#{id}/share/" }
  end

  describe "share" do
    context "PATCH" do
      before(:each) do
        sign_in user

        @folder = FactoryBot.build(:folder)
        @folder.user = user
        @folder.save
      end

      it "creates the token" do
        expect(@folder.share_token).to be_nil
        share_with_patch.call(@folder.id)
        expect(@folder.reload.share_token).to be_truthy
        expect(@folder.share_token
          .match(/\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\Z/i).present?).to be true
      end

      it "redirects to shared" do
        share_with_patch.call(@folder.id)
        expect(response.request.url).to end_with("folders/#{@folder.id}/share")
        expect(response.redirect?).to be true
        expect(response.location).to end_with("folders/#{@folder.reload.share_token}/shared")
      end
    end
  end
end
