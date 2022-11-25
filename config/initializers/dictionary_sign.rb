# Conditionally switch between dictionary sign models based on an environment variable.
# This allows us to quickly switch between searching Freelex and Signbank data for signs.

Rails.application.reloader.to_prepare do
  dictionary_mode = ENV["DICTIONARY_MODE"]&.downcase
  dictionary_sign_model = dictionary_mode == "freelex" ? FreelexSign : DictionarySign
  Rails.application.config.dictionary_sign_model = dictionary_sign_model

  ##
  # All other tables make heavy use of a 'word' column. Add an alias for it here so that
  # we can use common queries and ordering.
  # There's no ADD COLUMN IF NOT EXISTS, so we just handle the error
  begin
    DictionarySign.connection.execute("ALTER TABLE words ADD COLUMN word text GENERATED ALWAYS AS (gloss)")
  rescue ActiveRecord::StatementInvalid => e
    raise e unless e.message == "SQLite3::SQLException: duplicate column name: word"
  end
end
