require "rails_helper"

RSpec.describe "Topic administration", type: :system do
  include AdministratePageHelpers
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:topics) { FactoryBot.create_list(:topic, 10) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before { visit_admin(:topics, admin: admin) }

  it_behaves_like "an Administrate dashboard", :topics, except: %i[destroy new edit]
end
