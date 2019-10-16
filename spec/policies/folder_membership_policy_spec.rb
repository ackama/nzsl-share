require "rails_helper"

RSpec.describe FolderMembershipPolicy do
  it { expect(described_class.superclass).to eq ApplicationPolicy }
end
