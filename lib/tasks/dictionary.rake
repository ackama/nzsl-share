namespace :dictionary do
  desc "Updates the NZSL dictionary packaged with the application to the latest release from Signbank"
  task update: :environment do
    repo = "odnzsl/nzsl-dictionary-scripts"
    filename = "nzsl.db"
    content_type = "application/vnd.sqlite3"
    release_uri = URI::HTTPS.build(host: "api.github.com", path: "/repos/#{repo}/releases/latest")
    release = JSON.parse(release_uri.open.read)
    database_asset = release["assets"].find do |asset|
      asset["name"] == filename && asset["content_type"] == content_type
    end

    database_url = database_asset.fetch("browser_download_url")
    File.binwrite("db/new-dictionary.sqlite3", URI.parse(database_url).open.read)

    database = SQLite3::Database.open("db/new-dictionary.sqlite3")
    fail "Database does not pass integrity check" unless database.integrity_check == [["ok"]]

    FileUtils.mv("db/new-dictionary.sqlite3", "db/nzsl-dictionary.db.sqlite3")

    puts "Updated db/nzsl-dictionary.db.sqlite3 to #{release["name"]}"
  end
end