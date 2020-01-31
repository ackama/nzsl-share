# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign_comment", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:sign) { FactoryBot.create(:sign, :published) }

  let(:create_params) { { comment: "my first comment" } }
  let(:reply_params) { { comment: "a reply to your comment" } }
  let(:update_params) { { comment: "updated comment" } }

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

  let(:update) do
    lambda { |sign, sign_comment|
      patch "/signs/#{sign.id}/comment/#{sign_comment.id}", params: { sign_comment: update_params }
    }
  end

  describe "controller actions" do
    before(:each) do
      sign_in user
    end

    describe "create" do
      it "will create an anonymous comment for an approved user" do
        user.update(approved: true)
        expect(sign.sign_comments.count).to eq 0
        anonymous.call(sign)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.anonymous).to be true
        expect(response).to redirect_to sign_path(sign)
      end

      context "when associating with a folder" do
        let(:folder) { FactoryBot.create(:folder) }
        let(:create_params) { super().merge(folder_id: folder.id) }

        it "creates the sign comment successfully" do
          user.update(approved: true)
          expect { create.call(sign) }.to change(sign.sign_comments, :count).by(1)
        end

        it "associates the comment with the folder" do
          user.update(approved: true)
          create.call(sign)
          comment = sign.sign_comments.last
          expect(comment.folder).to eq folder
        end
      end
    end

    describe "destroy" do
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

    describe "update" do
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

    describe "appropriate" do
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

    describe "reply" do
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
