module AdministratePageHelpers
  def visit_admin(path, namespace: "/admin", admin: FactoryBot.create(:user, administrator: true))
    sign_in admin
    visit [namespace, path].join("/")
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
end
