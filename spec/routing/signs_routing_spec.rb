# frozen_string_literal: true

require "rails_helper"

RSpec.describe SignsController, type: :routing do
  describe "routing" do
    describe "/signs/search" do
      it("routes to signs#search on /search with a GET") do
        expect(get: "/signs/search").to route_to("signs#search")
      end
    end
  end
end
