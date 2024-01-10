require "rails_helper"

RSpec.describe "application/_footer.html.erb", type: :view do
  it "displays the DictionarySign version in the footer" do
    allow(DictionarySign).to receive(:version).and_return(20_230_101)
    render
    expect(rendered).to have_content "Dictionary database version: 20230101"
  end

  it "does not display the DictionarySign version text in the footer when the version is missing" do
    allow(DictionarySign).to receive(:version).and_return(nil)
    render
    expect(rendered).not_to have_content "Dictionary database version"
  end
end
