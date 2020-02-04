require "rails_helper"

RSpec.describe SignFolderButtonHelper, type: :helper do
  describe "#folder_button" do
    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:user_signed_in?).and_return(user.present?)
    end

    let(:sign) { SignPresenter.new(FactoryBot.create(:sign), helper) }

    # Wrap HTML we get back to use Capybara matchers
    subject { Capybara.string(helper.folder_button(sign)) }

    context "signed in" do
      let(:user) { sign.contributor }

      context "sign is in user folders" do
        before do
          folder = FactoryBot.create(:folder, user_id: user.id)
          FactoryBot.create(:folder_membership, folder: folder, sign: sign.object)
        end

        it "shows the add to folder button with the --in-folder state" do
          expect(subject).to have_button "Folders",
                                         class: "sign-card__folders__button sign-card__folders__button--in-folder"
        end
      end

      context "sign is in non-user folders" do
        before do
          FactoryBot.create(:folder_membership, sign: sign.object)
        end

        it "shows the add to folder button without the --in-folder state" do
          expect(subject).to have_button "Folders", class: "sign-card__folders__button"
        end
      end
      context "sign is in no folders" do
        it "shows the normal add to folder button" do
          expect(subject).to have_button "Folders", class: "sign-card__folders__button"
        end
      end
    end

    context "not signed in" do
      let(:user) { nil }

      it "shows a link to the user sign in page disguised as a add to folder button" do
        expect(subject).to have_link "Folders",
                                     href: new_user_session_path,
                                     class: "sign-card__folders__button"
      end
    end
  end
end
