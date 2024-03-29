# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign", type: :request do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, contributor: user) }

  before { sign_in user }

  describe "POST create" do
    let(:sign_params) { { video: fixture_file_upload("spec/fixtures/dummy.mp4") } }
    let(:params) { { sign: sign_params } }

    it "creates the sign"  do
      expect { post signs_path, params: }.to change(user.signs, :count).by(1)
    end

    it "initially records the sign as unmodified by the user" do
      post(signs_path, params:)
      sign = Sign.order(created_at: :desc).first
      expect(sign.last_user_edit_at).to be_nil
    end

    it "adds a flash message and redirects to the edit sign page" do
      post(signs_path, params:)
      expect(response).to redirect_to edit_sign_path(Sign.order(created_at: :desc).first)
      expect(flash[:notice]).to eq I18n.t("signs.create.success")
    end

    it "does not add a flash message and redirects to the my signs page with batch=true" do
      params[:batch] = true
      post(signs_path, params:)
      expect(response).to redirect_to user_signs_path
      expect(flash[:notice]).to be_nil
    end
  end

  describe "PATCH /:id" do
    let(:sign_params) { { notes: "this is a note for a sign" } }
    let(:update) do
      ->(sign) { patch "/signs/#{sign.id}", params: { sign: sign_params } }
    end

    it "post-processes sign videos when it is provided" do
      new_video = fixture_file_upload("spec/fixtures/small.mp4")
      sign_params[:video] = new_video
      allow(SignPostProcessor).to receive(:new).and_return(double.as_null_object)
      update.call(sign)

      expect(SignPostProcessor).to have_received(:new).with(sign)
    end

    it "does not post process sign videos when the sign video is not provided" do
      allow(SignPostProcessor).to receive(:new)
      update.call(sign)

      expect(SignPostProcessor).not_to have_received(:new).with(sign)
    end

    it "does not change sign ownership after update" do
      expect { update.call(sign) }.not_to change { sign.tap(&:reload).contributor }
    end

    it "updates the timestamp when the record was last user modified" do
      expect { update.call(sign) }.to change { sign.tap(&:reload).last_user_edit_at }
    end

    context "when the sign has been published" do
      let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }

      it "does not post process sign videos" do
        new_video = fixture_file_upload("spec/fixtures/small.mp4")
        sign_params[:video] = new_video
        allow(SignPostProcessor).to receive(:new).and_return(double.as_null_object)
        update.call(sign)

        expect(SignPostProcessor).not_to have_received(:new).with(sign)
      end
    end
  end

  describe "GET show" do
    let(:sign) { FactoryBot.create(:sign, :published, contributor: user) }

    it "marks unseen comments as read" do
      read = FactoryBot.create_list(:sign_comment, 5, sign:).each do |comment|
        comment.read_by!(user)
      end

      unread = FactoryBot.create_list(:sign_comment, 5, sign:)

      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(unread.count)
      expect(read.map { |r| r.read_by?(user) }.all?).to be true
      expect(unread.map { |r| r.read_by?(user) }.all?).to be true
    end

    it "only marks one page of comments as read at a time" do
      # Page size of 10
      FactoryBot.create_list(:sign_comment, 15, sign:)
      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(10)
      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(0)
      expect { get sign_path(sign, comments_page: 2) }.to change(SignCommentActivity.read, :count).by(5)
    end

    it "marks each seen comment's replies as read" do
      unread = FactoryBot.create(:sign_comment, sign:)
      reply_depth_1 = FactoryBot.create(:sign_comment, sign:, in_reply_to: unread)
      reply_depth_2 = FactoryBot.create(:sign_comment, sign:, in_reply_to: reply_depth_1)

      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(3)
      expect(unread).to be_read_by(user)
      expect(reply_depth_1).to be_read_by(user)
      expect(reply_depth_2).to be_read_by(user)
    end

    it "marks an unread reply as read, even if the original comment is already read" do
      read = FactoryBot.create(:sign_comment, sign:)
      read.read_by!(user)
      reply = FactoryBot.create(:sign_comment, sign:, in_reply_to: read)

      expect { get sign_path(sign) }.to change(SignCommentActivity.read, :count).by(1)
      expect(read).to be_read_by(user)
      expect(reply).to be_read_by(user)
    end

    it "doesn't mark comments as read when there is no user signed in" do
      sign_out :user
      FactoryBot.create(:sign_comment, sign:)
      expect { get sign_path(sign) }.not_to change(SignCommentActivity.read, :count)
    end
  end
end
