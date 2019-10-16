class AuthenticateFeature
  include Capybara::DSL

  attr_reader :user
  def initialize(user=FactoryBot.create(:user))
    @user = user
  end

  def sign_in
    visit "/users/sign_in"
    return if current_path != "/users/sign_in"

    within "form#new_user" do
      fill_in "Username/Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Log in"
    end
  end

  def sign_out
    click_on "Log out"
  end
end
