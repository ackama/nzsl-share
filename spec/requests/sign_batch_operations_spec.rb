require "rails_helper"

RSpec.describe "/signs/batch_operation", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:sign) { FactoryBot.create(:sign, contributor: user) }

  describe "POST create" do
    before { sign_in user }

    it "responds with the expected JSON" do
      params = { operation: :assign_topic, sign_ids: [1] }
      post signs_batch_operations_path(params: params, format: :json)
      expect(response).to be_ok
      response_json = JSON.parse(response.body)
      expect(response_json).to eq("succeeded" => [], "failed" => [])
    end

    it "responds with the expected HTML" do
      params = { operation: :assign_topic, sign_ids: [1] }
      post signs_batch_operations_path(params: params)
      expect(response).to redirect_to user_signs_path(sign_ids: [1])
      expect(flash[:notice]).to eq "Successfully processed 0 sign(s), 0 failed to process"
    end

    it "rejects an invalid operation name" do
      params = { operation: :does_not_exist, sign_ids: [1] }
      post signs_batch_operations_path(params: params)
      expect(response.status).to eq 422
    end

    context "when topics are assigned to signs" do
      let(:topic) { FactoryBot.create(:topic) }

      it "updates the topic assigned to the signs" do
        params = { operation: :assign_topic, sign_ids: [sign.id], topic_id: topic.id }
        expect do
          post signs_batch_operations_path(params: params)
        end.to change { sign.tap(&:reload).topics }
      end

      it "fails a record that does not pass the authorisation check" do
        sign.conditions_accepted = true
        sign.submit!
        sign.publish!
        params = { operation: :assign_topic, sign_ids: [sign.id], topic_id: topic.id }
        expect do
          post signs_batch_operations_path(params: params, format: :json)
        end.not_to change { sign.topics }

        response_json = JSON.parse(response.body)
        expect(response_json["failed"]).to eq [sign.as_json]
      end
    end

    context "when signs are submitted to be published" do
      it "submits the signs" do
        user.update(approved: true)
        params = { operation: :submit_for_publishing, sign_ids: [sign.id] }
        post signs_batch_operations_path(params: params)
        expect(sign.tap(&:reload).submitted?).to eq(true)
      end

      it "fails a record that has already been published" do
        user.update(approved: true)
        sign.conditions_accepted = true
        sign.submit!
        sign.publish!
        params = { operation: :submit_for_publishing, sign_ids: [sign.id] }
        expect do
          post signs_batch_operations_path(params: params, format: :json)
        end.not_to change { sign.status }

        response_json = JSON.parse(response.body)
        expect(response_json["failed"]).to eq [sign.as_json]
      end

      it "fails a record id the owner is not an approved user" do
        params = { operation: :submit_for_publishing, sign_ids: [sign.id] }
        expect do
          post signs_batch_operations_path(params: params, format: :json)
        end.not_to change { sign.status }

        response_json = JSON.parse(response.body)
        expect(response_json["failed"]).to eq [sign.as_json]
      end
    end
  end
end
