class ContributeSignFeature
  include Capybara::DSL
  include WaitForPath
  attr_reader :user

  def start(user=FactoryBot.create(:user))
    @user = user
    sign_in user
    click_on "Add a sign"
  end

  def drop_file_in_file_upload
    page.driver.execute_script(
      <<-JS
        dt = new DataTransfer();
        evt = jQuery.Event('drop', {
          preventDefault: function () {},
          stopPropagation: function () {},
          originalEvent: {
            dataTransfer: dt,
          }
        })
        dt.items.add(
          new File(
            ['foo'],
            'filenamme',
            {type: "video/mp4"}
          )
        )
        $(document).trigger(evt)
      JS
    )
    wait_for_path
  end

  def choose_file(path=default_attachment_path)
    page.attach_file("Browse files", path)
  end

  def submit
    return wait_for_path if supports_javascript?

    click_on("Start Upload")
  end

  def has_error?(message)
    within "#sign-upload-errors" do
      page.has_selector?("li", text: message)
    end
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
