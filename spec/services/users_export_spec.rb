require "rails_helper"

RSpec.describe UsersExport, type: :service do
  let!(:world) { UsersExportWorld.new.setup }
  subject(:export) { described_class.new }

  describe ".results" do
    subject(:results) { export.results }

    it "includes the expected number of results" do
      expect(results.size).to eq world.users.size
    end

    it "includes the expected data for a user with all roles" do
      user = world.all_roles_user
      result = results.first
      expect(result).to eq({
        username: user.username,
        email: user.email,
        number_of_signs: world.all_roles_user_signs.size,
        roles: "Admin,Validator,Moderator,Approved"
      }.stringify_keys)
    end

    it "includes the expected role string for a moderator" do
      result = results.second
      expect(result["roles"]).to eq "Moderator"
    end

    it "includes the expected role string for a basic user" do
      result = results.last
      expect(result["roles"]).to eq "Basic"
    end
  end

  describe ".to_csv" do
    subject(:csv) { export.to_csv }

    it "builds the expected CSV structure" do
      lines = csv.split("\n")
      expect(lines.first).to eq "username,email,number_of_signs,roles"
      expect(lines.size).to eq world.users.size + 1 # Headers
    end
  end
end

class UsersExportWorld
  attr_reader :users, :all_roles_user, :no_roles_user, :moderator_user, :all_roles_user_signs

  def setup
    @users = []
    @users << @all_roles_user = FactoryBot.create(:user, :administrator,
                                                  :validator, :moderator, :approved, username: "AAAA")
    @users << @no_roles_user = FactoryBot.create(:user, username: "ZZZ")
    @users << @moderator_user = FactoryBot.create(:user, :moderator, username: "BBB")
    @unconfirmed_user = FactoryBot.create(:user, confirmed_at: nil)
    @all_roles_user_signs = FactoryBot.create_list(:sign, 2, contributor: @all_roles_user)

    self
  end
end
