class Admin::ExportsController < Admin::ApplicationController
  def index
  end

  def published_signs
    send_data PublishedSignsExport.new.to_csv, filename: "published-signs.csv", type: "text/csv"
  end

  def users
    send_data UsersExport.new.to_csv, filename: "users.csv", type: "text/csv"
  end
end
