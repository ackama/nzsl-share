require "rails_helper"

RSpec.describe DictionarySign, type: :model do
  it "uses the expected .table_name" do
    expect(described_class.table_name).to eq "words"
  end

  it "uses the expected connection" do
    expect(described_class.connection.adapter_name).to eq "SQLite"
  end

  it "filters out obscene entries by default" do
    sign = DictionarySign.create!(usage: "obscene", id: SecureRandom.uuid)
    expect(DictionarySign.unscoped.where(id: sign.id)).to eq [sign]
    expect(DictionarySign.where(id: sign.id)).to be_empty
  end

  it "defines the preview scope to not include too many results" do
    signs = Array.new(5) { DictionarySign.create!(id: SecureRandom.uuid) }
    expect(DictionarySign.where(id: signs.map(&:id)).preview.length).to eq 4
  end

  it "aliases methods to be compatible with FreelexSign" do
    sign = DictionarySign.new(gloss: "GLOSS", minor: "SECONDARY")
    expect(sign.word).to eq sign.gloss
    expect(sign.secondary).to eq sign.secondary
  end
end
