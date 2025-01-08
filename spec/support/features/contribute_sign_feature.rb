require_relative "file_uploads"
require_relative "../wait_for_path"

class ContributeSignFeature
  include Capybara::DSL
  include WaitForPath
  include FileUploads
  attr_reader :user

  def start
    visit "/signs/new"
  end

  def submit
    click_on("Start Upload") unless supports_javascript? # In this case, the form is submitted automatically
    page.has_content?(I18n.t("signs.create.success"))
  end

  def has_error?(message)
    page.has_content?(message)
  end

  private

  def supports_javascript?
    Capybara.current_driver != :rack_test
  end
end
