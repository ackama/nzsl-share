require "rails_helper"

RSpec.describe "User administration", type: :system do
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:users) { FactoryBot.create_list(:user, 3) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before { visit_admin(:users) }

  it_behaves_like "an Administrate dashboard", :users, except: %i[destroy new]
end
