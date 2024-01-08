namespace :dictionary do
  desc "Updates the NZSL dictionary packaged with the application to the latest release from Signbank"
  task :update do # rubocop:disable Rails/RakeEnvironment - we need to place this file before the app can start
    database_s3_location = URI.parse(ENV.fetch("DICTIONARY_DATABASE_S3_LOCATION") || "")
    client = s3_client(region: ENV.fetch("DICTIONARY_AWS_REGION", ENV.fetch("AWS_REGION", nil)),
                       access_key_id: ENV.fetch("DICTIONARY_AWS_ACCESS_KEY_ID", nil),
                       secret_access_key: ENV.fetch("DICTIONARY_AWS_SECRET_ACCESS_KEY", nil))

    fail "DICTIONARY_DATABASE_S3_LOCATION must be an S3 URI" unless database_s3_location.scheme == "s3"

    download_s3_uri(database_s3_location, "db/new-dictionary.sqlite3", client:)

    database = SQLite3::Database.open("db/new-dictionary.sqlite3")
    fail "Database does not pass integrity check" unless database.integrity_check == [["ok"]]

    version = database.get_int_pragma("user_version")

    FileUtils.mv("db/new-dictionary.sqlite3", "db/nzsl-dictionary.db.sqlite3")

    puts "Updated db/nzsl-dictionary.db.sqlite3 to #{version}"
  end

  def s3_client(region:, access_key_id: nil, secret_access_key: nil)
    opts = { region:, credentials: nil }
    opts[:credentials] = Aws::Credentials.new(access_key_id, secret_access_key) if access_key_id && secret_access_key

    Aws::S3::Client.new(opts)
  end

  def download_uri(uri, target_path)
    uri = URI.parse(uri) unless uri.is_a?(URI)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      response = http.get(uri.request_uri).tap(&:value)
      File.binwrite(target_path, response.body)
    end
  end

  def download_s3_uri(s3_uri, target_path, client:)
    s3_object = Aws::S3::Object.new(s3_uri.host, s3_uri.path[1..], client:)
    uris_to_try = [s3_object.public_url, s3_object.presigned_url(:get, expires_in: 60)]

    downloaded_uri = uris_to_try.detect do |uri|
      download_uri(uri, target_path)
      true
    rescue Net::HTTPClientException => e
      next if e.message == "403 \"Forbidden\""

      raise "Failed to download #{s3_uri}: #{e}"
    end

    fail "Failed to download #{s3_uri}: All URIs have been tried" unless downloaded_uri
  end
end
