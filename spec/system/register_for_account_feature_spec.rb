require "rails_helper"

RSpec.describe "Registering for an account", type: :system do
  before { visit new_user_registration_path }
  let(:user) { FactoryBot.build(:user) }

  it "can sign up with valid attributes" do
    complete_form
    submit_form
    expect(page).to have_content "You have signed up successfully."
  end

  it "is presented with errors for invalid fields" do
    complete_form
    fill_in "Email", with: ""
    submit_form
    expect(page).to have_content "Email can't be blank"
  end

  private

  def complete_form
    fill_in "Username", with: user.username
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Password confirmation", with: user.password
  end

  def submit_form
    click_on "Sign up"
  end
end
