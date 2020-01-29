require "rails_helper"

RSpec.describe SignComment, type: :model do
  subject(:model) { FactoryBot.build(:sign_comment) }

  it { is_expected.to be_valid }
end
