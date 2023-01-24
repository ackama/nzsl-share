require "rails_helper"

RSpec.describe SignPolicy do
  let(:user) { FactoryBot.create(:user, :moderator) }

  subject(:policy) { described_class.new(user, Sign) }

  it "inherits from ApplicationPolicy" do
    expect(described_class.superclass).to eq ApplicationPolicy
  end

  describe "scope" do
    describe "user as moderator" do
      it { expect(user.moderator).to be true }
      it { expect(Pundit.policy_scope!(user, Sign)).to eq [] }

      context "signs" do
        it "has scope for public signs" do
          FactoryBot.create_list(:sign, 3, :published)
          scope = Pundit.policy_scope!(user, Sign)
          expect(scope.count).to eq 3
          expect(scope.map(&:status).uniq).to eq ["published"]
        end

        it "has scope for its own private signs" do
          FactoryBot.create_list(:sign, 3, :personal, contributor: user)
          scope = Pundit.policy_scope!(user, Sign)
          expect(scope.count).to eq 3
          expect(scope.map(&:status).uniq).to eq ["personal"]
        end

        it "applies any existing clauses on the scope" do
          signs = FactoryBot.create_list(:sign, 3, :personal, contributor: user)
          scope = Pundit.policy_scope!(user, Sign.where(id: signs.last))
          expect(scope.count).to eq 1
          expect(scope.first).to eq signs.last
        end

        it "does not have scope for other users private signs" do
          FactoryBot.create_list(:sign, 3, :personal)
          scope = Pundit.policy_scope!(user, Sign)
          expect(scope.count).to eq 0
          expect(scope.map(&:status).uniq).to eq []
        end

        it "has scope for its own private signs and public signs but not other users private signs" do
          FactoryBot.create_list(:sign, 3, :personal)
          FactoryBot.create_list(:sign, 3, :published)
          FactoryBot.create_list(:sign, 3, :personal, contributor: user)
          scope = Pundit.policy_scope!(user, Sign)
          expect(scope.count).to eq 6
          expect(scope.map(&:status).uniq.sort).to eq %w[personal published]
        end
      end
    end
  end
end
