require "rails_helper"

RSpec.describe "User administration", type: :system do
  include AdministratePageHelpers

  let!(:users) { FactoryBot.create_list(:user, 3) }
  before { visit_admin(:users) }
  it_behaves_like "an Administrate dashboard", :users, except: %i[destroy new]
end
