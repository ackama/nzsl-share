require "rails_helper"

RSpec.describe DictionarySign, type: :model do
  it "uses the expected .table_name" do
    expect(described_class.table_name).to eq "words"
  end

  it "uses the expected connection" do
    expect(described_class.connection.adapter_name).to eq "SQLite"
  end

  it "wraps the video attribute with a value object" do
    sign = FactoryBot.create(:dictionary_sign, video: "https://example.com/video.mp4", id: SecureRandom.uuid)
    expect(sign.video).to eq URI.parse("https://example.com/video.mp4")
  end

  it "guards against a blank video attribute value" do
    sign = FactoryBot.create(:dictionary_sign, video: "", id: SecureRandom.uuid)
    expect(sign.video).to be_nil
  end

  it "filters out obscene entries by default" do
    sign = FactoryBot.create(:dictionary_sign, usage: "obscene", id: SecureRandom.uuid)
    expect(DictionarySign.unscoped.where(id: sign.id)).to eq [sign]
    expect(DictionarySign.where(id: sign.id)).to be_empty
  end

  it "defines the preview scope to not include too many results" do
    signs = FactoryBot.create_list(:dictionary_sign, 5)
    expect(DictionarySign.where(id: signs.map(&:id)).preview.length).to eq 4
  end

  it "aliases methods to be compatible with Sign" do
    sign = FactoryBot.create(:dictionary_sign, gloss: "GLOSS", minor: "SECONDARY")
    expect(sign.word).to eq sign.gloss
    expect(sign.secondary).to eq sign.secondary
  end
end
