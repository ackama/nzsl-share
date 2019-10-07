require "rails_helper"

RSpec.describe "Sign show page", system: true do
  subject { SignPage.new }
  let(:sign) { subject.sign }

  before { subject.start }

  it "displays the sign word" do
    expect(subject).to have_selector "h2", text: sign.english
  end

  it "displays the sign video" do
    expect(subject).to have_selector ".sign-card__media > iframe[src^='https://player.vimeo.com']"
  end

  it "displays the contributor's username" do
    expect(subject).to have_content sign.contributor.username
  end

  it "displays the sign topic" do
    expect(subject).to have_content sign.topic.name
  end

  it "shows a breadcrumb to the sign" do
    subject.breadcrumb { expect(subject).to have_content "Current: #{sign.english}" }
  end

  it "shows a breadcrumb to the topic" do
    subject.breadcrumb { expect(subject).to have_link sign.topic.name }
  end

  it "displays the sign description" do
    sign.update!(description: "Hello, world!")
    visit current_path # Reload
    expect(subject).to have_selector "p", text: "Hello, world!"
  end
end
