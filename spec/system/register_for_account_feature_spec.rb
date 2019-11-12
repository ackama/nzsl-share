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

  it "doesn't create any folders unless the user successfully registered" do
    expect do
      complete_form
      fill_in "Email", with: ""
      submit_form
    end.not_to change(Folder, :count)
  end

  it "has a default folder created after signing up" do
    expect do
      complete_form
      submit_form
    end.to change(Folder, :count).by(1)

    click_on "My folders"
    expect(page).to have_content I18n.t("folders.default_title")
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
