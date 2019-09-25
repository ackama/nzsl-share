# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchController, type: :routing do
  describe "routing" do
    describe "/search" do
      it { expect(get: "/search").to route_to("search#index") }
    end
  end
end
