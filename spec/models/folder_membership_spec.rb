require "rails_helper"

RSpec.describe FolderMembership, type: :model do
  subject { FactoryBot.build(:folder_membership) }
  it { is_expected.to be_valid }
end
