require "rails_helper"

RSpec.describe "Topic administration", type: :system do
  include AdministratePageHelpers
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:topics) { FactoryBot.create_list(:topic, 10) }

  before { visit_admin(:topics, admin: admin) }

  it_behaves_like "an Administrate dashboard", :topics, except: %i[show]

  it "can visit the show page" do
    click_on_first_row
    expect(header).to start_with topics.first.name
  end
end
