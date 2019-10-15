class ContributeSignFeature
  include Capybara::DSL
  include WaitForPath
  attr_reader :user

  def start(user=FactoryBot.create(:user))
    @user = user
    sign_in user
    click_on "Add a sign"
  end

  def choose_file(path=default_attachment_path)
    page.attach_file("Browse files", path)
  end

  def submit
    click_on("Start Upload")
    wait_for_path if supports_javascript?
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

  def default_attachment_path
    Rails.root.join("spec", "fixtures", "dummy.mp4")
  end

  def supports_javascript?
    Capybara.current_driver != :rack_test
  end
end
