# frozen_string_literal: true

require "rails_helper"

RSpec.describe SignsController, type: :routing do
  describe "routing" do
    describe "/signs" do
      it { expect(get: "/signs").to route_to("signs#index") }
    end
  end
end
