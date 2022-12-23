class ApprovedUserApplicationFeature
  include Capybara::DSL

  def start(application = FactoryBot.build(:approved_user_application))
    @application = application
    visit "/approved_user_applications/new"
  end

  def fill_in_mandatory_fields
    fill_in "First name", with: @application.first_name
    fill_in "Last name", with: @application.last_name
    choose "Deaf"
    choose "your first language (used from childhood)"
  end

  def submit
    click_on "Submit"
  end
end
