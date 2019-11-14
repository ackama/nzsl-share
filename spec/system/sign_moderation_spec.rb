require "rails_helper"

RSpec.describe "Sign moderation", type: :system do
  let!(:signs) { FactoryBot.create_list(:sign, 3) }
  it_behaves_like "an Administrate dashboard", :signs
end
