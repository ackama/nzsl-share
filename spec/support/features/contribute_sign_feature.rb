require_relative "./file_uploads"

class ContributeSignFeature
  include Capybara::DSL
  include WaitForPath
  include FileUploads
  attr_reader :user

  def start(user=FactoryBot.create(:user))
    @user = user
    sign_in user
    within ".sidebar--inside-grid" do
      click_on "Add a sign"
    end
  end

  def submit
    return wait_for_path if supports_javascript?

    click_on("Start Upload")
  end

  def has_error?(message)
    page.has_content?(message)
  end

  def sign_in(user)
    visit "/users/sign_in"
    return if current_path != "/users/sign_in"

    within "form#new_user" do
      fill_in "Username/Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Log in"
    end
  end

  private

  def supports_javascript?
    Capybara.current_driver != :rack_test
  end
end
