require "rails_helper"

RSpec.describe SignCommentPolicy, type: :policy do
  describe described_class::Scope do
    def resolve(user, scope = SignComment)
      described_class.new(user, scope).resolve
    end

    it "resolves a comment on a published sign" do
      sign = FactoryBot.create(:sign, :published)
      comment = FactoryBot.create(:sign_comment, sign:)
      expect(resolve(comment.user)).to include comment
    end

    it "resolves a comment on a private sign accessible to the user" do
      sign = FactoryBot.create(:sign)
      comment = FactoryBot.create(:sign_comment, sign:, user: sign.contributor)
      expect(resolve(comment.user)).to include comment
    end

    it "does not resolve a comment on a private sign inaccessible to the user" do
      user = FactoryBot.create(:user)
      sign = FactoryBot.create(:sign)
      comment = FactoryBot.create(:sign_comment, sign:, user:)
      expect(resolve(user)).not_to include comment
    end

    it "does not resolve a folder comment on a private sign when the sign no longer belongs to the folder" do
      folder = FactoryBot.create(:folder)
      sign = FactoryBot.create(:sign, contributor: folder.user)
      comment = FactoryBot.create(:sign_comment, folder:, sign:)
      expect(resolve(folder.user)).not_to include comment
    end

    it "resolves a folder comment on a private sign" do
      folder = FactoryBot.create(:folder)
      folder.signs << sign = FactoryBot.create(:sign, contributor: folder.user)
      comment = FactoryBot.create(:sign_comment, folder:, sign:)
      expect(resolve(folder.user)).to include comment
    end

    it "does not resolve an uncollaborated folder comment" do
      user = FactoryBot.create(:user)
      folder = FactoryBot.create(:folder)
      folder.signs << sign = FactoryBot.create(:sign)
      comment = FactoryBot.create(:sign_comment, folder:, sign:)
      expect(resolve(user)).not_to include comment
    end
  end
end
