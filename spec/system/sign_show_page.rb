require "rails_helper"

RSpec.describe "Sign show page", system: true do
  subject { SignPage.new }
  let(:sign) { subject.sign }

  before { subject.start }

  it "displays the sign word" do
    expect(subject).to have_selector "h1", text: sign.english
  end

  it "displays the sign video" do
    expect(subject).to have_selector ".responsive-embed > iframe[src^='https://player.vimeo.com']"
  end

  it "displays the contributor's username" do
    expect(subject).to have_content sign.contributor.username
  end

  it "displays the sign topic" do
    expect(subject).to have_content sign.topic.name
  end
end
