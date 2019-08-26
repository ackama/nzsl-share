require "rails_helper"

RSpec.describe "Style guide", type: :system do
  before { visit styleguide_path }
  it_behaves_like "an accessible page"
end
