class FolderFeature
  include Capybara::DSL
  attr_reader :user, :folder

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

  def submit_new_collaborator_form
    click_on "Create Collaboration"
  end

  def enter_identifier(identifier)
    fill_in "collaboration_identifier", with: identifier
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

  def within_specific_list_item_menu(title, dropdown: false)
    within(find(".small-5", text: title, visible: true).first(:xpath, ".//..")) do
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

  def manage_collaborators(dropdown: false)
    within_list_item_menu(dropdown: dropdown) do
      click_on "Team Members"
    end
  end
end
