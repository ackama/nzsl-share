module AdministratePageHelpers
  def visit_admin(path, namespace: "/admin", admin: FactoryBot.create(:user, administrator: true))
    visit [namespace, path].join("/")
    sign_in admin
  end

  def header
    find("h1").text
  end

  def click_on_first_row
    first_row.all("td a").first.click
  end

  def first_row
    all("tr.js-table-row").first
  end

  def mid_row
    all("tr.js-table-row")[1]
  end

  def last_row
    all("tr.js-table-row").last
  end

  def sign_in(user)
    # We're already signed in
    return if current_path != "/users/sign_in"

    within "form#new_user" do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Log in"
    end
  end
end
