require "rails_helper"

RSpec.describe SignComment, type: :model do
  subject(:model) { FactoryBot.build(:sign_comment) }

  it { is_expected.to be_valid }

  context "without a folder" do
    before { model.folder = nil }
    it { is_expected.to be_valid }
  end

  context "with a folder" do
    subject(:model) { FactoryBot.build(:sign_comment, :with_folder) }
    it { is_expected.to be_valid }
    it { expect(model.folder).to be_a Folder }
  end
end
