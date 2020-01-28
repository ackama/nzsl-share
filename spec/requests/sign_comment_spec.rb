# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign_comment", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:sign) { FactoryBot.create(:sign, :published) }
  let(:create_params) { { comment: "my first comment" } }
  let(:reply_params) { { comment: "a reply to your comment" } }

  let(:create) do
    ->(sign) { post "/signs/#{sign.id}/comment", params: { sign_comment: create_params } }
  end

  let(:anonymous) do
    ->(sign) { post "/signs/#{sign.id}/comment", params: { sign_comment: create_params.merge(anonymous: true) } }
  end

  let(:destroy) do
    ->(sign, sign_comment) { delete "/signs/#{sign.id}/comment/#{sign_comment.id}" }
  end

  let(:appropriate) do
    ->(sign, sign_comment) { patch "/signs/#{sign.id}/comment/#{sign_comment.id}/appropriate" }
  end

  let(:reply) do
    lambda { |sign, sign_comment|
      post "/signs/#{sign.id}/comment/", params: { sign_comment: reply_params.merge(parent_id: sign_comment.id) }
    }
  end

  describe "controller actions" do
    before(:each) do
      sign_in user
    end

    context "create" do
      it "will create a comment for an approved user" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(response).to redirect_to sign_path(sign)
      end

      it "will not create a comment for an unapproved user" do
        user.update(approved: false)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 0
      end

      it "will create an anonymous comment for an approved user" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        anonymous.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.anonymous).to be true
        expect(response).to redirect_to sign_path(sign)
      end
    end

    context "destroy" do
      it "deletes a sign comment" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        destroy.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 0
        expect(response).to redirect_to sign_path(sign)
      end
    end

    context "appropriate" do
      it "it flags a comment as inapprppriate" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.appropriate).to be true
        appropriate.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.first.appropriate).to be false
        expect(response).to redirect_to sign_path(sign)
      end
    end

    context "reply" do
      it "will create a reply for an approved user" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.replies.count).to eq 0
        reply.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.first.replies.count).to eq 1
        expect(response).to redirect_to sign_path(sign)
      end

      it "will not create a reply for an unapproved user" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.replies.count).to eq 0
        user.update(approved: false)
        reply.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.first.replies.count).to eq 0
      end
    end
  end
end
