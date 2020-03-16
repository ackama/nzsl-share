# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sign", type: :request do
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :published) }

  let(:update) do
    ->(sign) { patch "/signs/#{sign.id}", params: { sign: { notes: "this is a note for a sign" } } }
  end

  describe "controller actions" do
    before(:each) do
      sign_in user
      sign.contributor = user
      sign.save
    end

    describe "update" do
      it "does not change sign ownership after update" do
        expect(sign.contributor).to eq user
        update.call(sign)
        expect(sign.contributor).to eq user
      end
    end
  end
end
