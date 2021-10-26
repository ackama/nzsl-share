require "rails_helper"

RSpec.describe PublishedSignsExport, type: :service do
  let!(:world) { PublishedSignsExportWorld.new.setup }
  subject(:export) { described_class.new }

  describe ".results" do
    subject(:results) { export.results }

    it "includes the expected number of results" do
      expect(results.size).to eq 2 # Published signs, excludes unpublished sign
    end

    it "includes the expected data" do
      sign = world.controversial_sign
      result = results.last # ordered by ID asc
      expect(result).to eq({
        id: sign.id,
        url: "https://www.nzslshare.nz/signs/#{sign.id}",
        word: sign.word,
        username: sign.contributor.username,
        email: sign.contributor.email,
        created_at: sign.created_at.utc.floor(6), # Match DB precision
        agrees: world.agrees.size,
        disagrees: world.disagrees.size
      }.stringify_keys)
    end
  end

  describe ".to_csv" do
    subject(:csv) { export.to_csv }

    it "builds the expected CSV structure" do
      lines = csv.split("\n")
      expect(lines.first).to eq "id,url,word,username,email,created_at,agrees,disagrees"
      expect(lines.size).to eq 3 # Headers plus 2 published signs
    end
  end
end

class PublishedSignsExportWorld
  attr_reader :published_sign, :controversial_sign, :agrees, :disagrees, :unpublished_sign

  def setup
    @published_sign = FactoryBot.create_list(:sign, 1, :published)
    @unpublished_sign = FactoryBot.create(:sign)
    @controversial_sign = FactoryBot.create(:sign, :published)
    @agrees = FactoryBot.create_list(:sign_activity, 5, key: SignActivity::ACTIVITY_AGREE,
                                                        sign: @controversial_sign)
    @disagrees = FactoryBot.create_list(:sign_activity, 5, key: SignActivity::ACTIVITY_DISAGREE,
                                                           sign: @controversial_sign)

    self
  end
end
