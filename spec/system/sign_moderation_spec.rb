require "rails_helper"

RSpec.describe "Sign moderation", type: :system do
  include AdministratePageHelpers
  let!(:moderator) { FactoryBot.create(:user, :moderator) }
  let(:auth) { AuthenticateFeature.new(moderator) }
  let!(:signs) { FactoryBot.create_list(:sign, 3, :published) }

  before { visit_admin(:signs, admin: moderator) }

  it_behaves_like "an Administrate dashboard", :signs, except: %i[destroy new show]

  context "filtering" do
    context "using dropdown" do
      it "filters by Pending" do
        select "Pending", from: "status"
        expect(page).to have_field "search", with: "pending:"
      end

      it "filters by published" do
        select "Published", from: "status"
        expect(page).to have_field "search", with: "published:"
      end

      it "filters by archived" do
        select "Archived", from: "status"
        expect(page).to have_field "search", with: "archived:"
      end
    end

    context "using search field" do
      it "filters a submitted sign" do
        sign = FactoryBot.create(:sign, :submitted)
        expect { submit_search("pending:") }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "filters a published sign" do
        sign = FactoryBot.create(:sign, :published)
        expect { submit_search("published:") }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "filters a unpublish requested sign" do
        sign = FactoryBot.create(:sign, :unpublish_requested)
        expect { submit_search("pending:") }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "filters a archived sign" do
        sign = FactoryBot.create(:sign, :archived)
        expect { submit_search("archived:") }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "searches user email" do
        sign = FactoryBot.create(:sign, :published)
        expect { submit_search(sign.contributor.email) }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "searches user username" do
        sign = FactoryBot.create(:sign, :published)
        expect { submit_search(sign.contributor.username) }.to change { page.has_content?(sign.word) }.to eq true
      end

      it "searches by word" do
        sign = FactoryBot.create(:sign, :published)
        expect { submit_search(sign.word) }.to change { page.has_content?(sign.word) }.to eq true
      end
    end
  end

  context "clicking links in table rows" do
    it "links to the sign's show page" do
      click_on_first_row
      expect(page).to have_current_path(sign_path(signs.first))
    end
  end

  private

  def submit_search(term)
    form = find("form.search")
    form.fill_in "Search Signs", with: term

    # Artificially submit the form. Normally the browser does this, but
    # Rack::Test can't.
    Capybara::RackTest::Form.new(page.driver, form.native).submit({})
  end
end
