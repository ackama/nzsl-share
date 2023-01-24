# Conditionally switch between dictionary sign models based on an environment variable.
# This allows us to quickly switch between searching Freelex and Signbank data for signs.

Rails.application.reloader.to_prepare do
  dictionary_mode = ENV["DICTIONARY_MODE"]&.downcase
  dictionary_sign_model = dictionary_mode == "freelex" ? FreelexSign : DictionarySign
  Rails.application.config.dictionary_sign_model = dictionary_sign_model
  next if dictionary_sign_model != DictionarySign

  # Update the dictionary file if it is older than 1 month
  path = Rails.root.join("db/nzsl-dictionary.db.sqlite3")
  Rails.application.load_tasks
  Rake::Task["dictionary:update"].execute if !path.exist? || path.mtime <= 1.month.ago

  ##
  # All other tables make heavy use of a 'word' column. Add an alias for it here so that
  # we can use common queries and ordering.
  # There's no ADD COLUMN IF NOT EXISTS, so we just handle the error
  begin
    DictionarySign.connection.execute("ALTER TABLE words ADD COLUMN word text AS (gloss)")
  rescue ActiveRecord::StatementInvalid => e
    raise e unless e.message == "SQLite3::SQLException: duplicate column name: word"
  end
end
