# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign_comment", type: :request do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :published) }

  let(:create_params) { { comment: "my first comment" } }
  let(:reply_params) { { comment: "a reply to your comment" } }
  let(:update_params) { { comment: "updated comment" } }

  let(:create) do
    ->(sign) { post "/signs/#{sign.id}/comments", params: { sign_comment: create_params } }
  end

  let(:anonymous) do
    ->(sign) { post "/signs/#{sign.id}/comments", params: { sign_comment: create_params.merge(anonymous: true) } }
  end

  let(:destroy) do
    lambda { |sign, sign_comment|
      delete "/signs/#{sign.id}/comments/#{sign_comment.id}",
             params: {},
             headers: { "HTTP_REFERER" => "http://www.example.com/signs/#{sign.id}" }
    }
  end

  let(:reply) do
    lambda { |sign, sign_comment|
      post "/signs/#{sign.id}/comments/", params: { sign_comment: reply_params.merge(parent_id: sign_comment.id) }
    }
  end

  let(:update) do
    lambda { |sign, sign_comment|
      patch "/signs/#{sign.id}/comments/#{sign_comment.id}", params: { sign_comment: update_params }
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
        expect(response).to redirect_to sign_path(sign, anchor: "sign_comment_#{sign.sign_comments.first.id}")
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
      it "will remove a comment for an administrator" do
        user.update(administrator: true)
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        destroy.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.removed).to be true
        expect(response).to redirect_to sign_path(sign, anchor: "sign_comment_#{sign.sign_comments.first.id}")
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
        expect(response).to redirect_to sign_path(sign, anchor: "sign_comment_#{sign.sign_comments.first.id}")
      end

      it "will update a comment for the commenter" do
        expect(sign.sign_comments.count).to eq 0
        create.call(sign)
        expect(sign.sign_comments.count).to eq 1
        update.call(sign, sign.sign_comments.first)
        expect(sign.sign_comments.count).to eq 1
        expect(sign.sign_comments.first.comment).to eq "updated comment"
        expect(response).to redirect_to sign_path(sign, anchor: "sign_comment_#{sign.sign_comments.first.id}")
      end

      it "retains the folder context of a comment" do
        folder = FactoryBot.create(:folder, user:)
        sign.folders << folder
        create_params[:folder_id] = folder.id
        create.call(sign)
        comment = sign.sign_comments.last
        update.call(sign, comment)
        expect { comment.reload }.not_to change(comment, :folder).from(folder)
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
        anchor = "sign_comment_#{sign.sign_comments.first.replies.first.id}"
        expect(response).to redirect_to sign_path(sign, anchor:)
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
