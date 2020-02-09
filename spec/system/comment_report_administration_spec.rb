require "rails_helper"

RSpec.describe "Comment report administration", type: :system do
  include AdministratePageHelpers
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:comment) { FactoryBot.create(:sign_comment) }
  let!(:comment_report) { FactoryBot.create(:comment_report, comment: comment) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before do
    visit_admin(:comment_reports, admin: admin)
  end

  it_behaves_like "an Administrate dashboard", :comment_reports, except: %i[destroy new edit]
end
