class FolderFeature
  include Capybara::DSL
  attr_reader :user

  def initialize(user=FactoryBot.create(:user))
    @user = user
  end

  def start
    sign_in user
    visit "/folders"
  end

  def click_create_new
    click_on "+ New folder"
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

  def submit_edit_folder_form
    click_on "Update Folder"
  end

  def edit_folder(dropdown: false)
    within(find(".folder", match: :first)) do
      click_on "Folder Options" if dropdown
      click_on "Edit"
    end
  end

  def remove_folder(dropdown: false)
    within(find(".folder", match: :first)) do
      click_on "Folder Options" if dropdown
      click_on "Delete"
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
end
