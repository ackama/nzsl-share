class ApprovedUserApplicationFeature
  include Capybara::DSL

  def start(user, demographic=FactoryBot.build(:demographic))
    @user = user
    @demographic = demographic
    sign_in user
    visit "/approved_users/new"
  end

  def fill_in_mandatory_fields
    fill_in "First name", with: @demographic.first_name
    fill_in "Last name", with: @demographic.last_name
    choose "Deaf"
    choose "your first language (used from childhood)"
  end

  def submit
    click_on "Submit"
  end

  private

  def sign_in(user)
    return unless user

    AuthenticateFeature.new(user).sign_in
  end
end
