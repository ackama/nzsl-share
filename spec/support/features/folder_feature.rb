class FolderFeature
  include Capybara::DSL
  attr_reader :user

  def initialize(user=FactoryBot.create(:user))
    @user = user
    sign_in
  end

  def start
    visit "/folders"
  end

  def click_create_new
    click_on "New Folder"
  end

  def enter_title(title)
    fill_in "folder_title", with: title
  end

  def enter_description(description)
    fill_in "folder_description", with: description
  end

  def submit_new_folder_form
    click_on "Create Folder"
  end

  def sign_in
    AuthenticateFeature.new(user).sign_in
  end

  def submit_edit_folder_form
    click_on "Update Folder"
  end

  def within_list_item_menu(dropdown: false)
    within(find(".list__item", match: :first)) do
      click_on "Folder Options" if dropdown
      yield
    end
  end

  def edit_folder(dropdown: false)
    within_list_item_menu(dropdown: dropdown) do
      click_on "Edit"
    end
  end

  def remove_folder(dropdown: false)
    within_list_item_menu(dropdown: dropdown) do
      click_on "Delete"
    end
  end
end
