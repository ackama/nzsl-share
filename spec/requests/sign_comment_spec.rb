# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign_comment", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:sign) { FactoryBot.create(:sign, :published) }
  let(:create_params) { { comment: "my first comment" } }
  let(:update_params) { { comment: "updated comment" } }

  let(:create) do
    ->(sign) { post "/signs/#{sign.id}/comment", params: { sign_comment: create_params } }
  end

  let(:destroy) do
    ->(sign, sign_comment) { delete "/signs/#{sign.id}/comment/#{sign_comment.id}" }
  end

  let(:update) do
    lambda { |sign, sign_comment|
      patch "/signs/#{sign.id}/comment/#{sign_comment.id}", params: { sign_comment: update_params }
    }
  end

  describe "controller actions" do
    before(:each) do
      sign_in user
    end

    context "create" do
      it "creates a sign comment" do
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(response).to redirect_to sign_path(sign)
      end
    end

    context "destroy" do
      it "will delete a comment for an administrator" do
        user.update(administrator: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        destroy.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 0
        expect(response).to redirect_to sign_path(sign)
      end

      it "will delete a comment for the sign owner" do
        sign.update(contributor: user)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        destroy.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 0
        expect(response).to redirect_to sign_path(sign)
      end
    end

    context "update" do
      it "will update a comment for an administrator" do
        user.update(administrator: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        update.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.comment).to eq "updated comment"
        expect(response).to redirect_to sign_path(sign)
      end

      it "will update a comment for the sign owner" do
        sign.update(contributor: user)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        update.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.comment).to eq "updated comment"
        expect(response).to redirect_to sign_path(sign)
      end
    end
  end
end
