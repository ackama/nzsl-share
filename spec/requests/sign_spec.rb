# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign", type: :request do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }

  before { sign_in user }

  describe "PATCH /:id" do
    let(:update) do
      ->(sign) { patch "/signs/#{sign.id}", params: { sign: { notes: "this is a note for a sign" } } }
    end

    it "does not change sign ownership after update" do
      expect(sign.contributor).to eq user
      update.call(sign)
      expect(sign.contributor).to eq user
    end
  end

  describe "GET show" do
    it "marks unseen comments as read" do
      read = FactoryBot.create_list(:sign_comment, 5, sign: sign).each do |comment|
        comment.read_by!(user)
      end

      unread = FactoryBot.create_list(:sign_comment, 5, sign: sign)

      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(unread.count)
      expect(read.map { |r| r.read_by?(user) }.all?).to be true
      expect(unread.map { |r| r.read_by?(user) }.all?).to be true
    end

    it "only marks one page of comments as read at a time" do
      # Page size of 10
      FactoryBot.create_list(:sign_comment, 15, sign: sign)
      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(10)
      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(0)
      expect { get sign_path(sign, comments_page: 2) }.to change(SignCommentActivity.read, :count).by(5)
    end

    it "doesn't mark comments as read when there is no user signed in" do
      sign_out :user
      FactoryBot.create(:sign_comment, sign: sign)
      expect { get sign_path(sign) }.not_to change(SignCommentActivity.read, :count)
    end
  end
end
