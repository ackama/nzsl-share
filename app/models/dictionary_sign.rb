##
# This model consumes dictionary data from a SQLite3 file produced by
# https://github.com/ODNZSL/nzsl-dictionary-scripts
#
# Some things to be aware of:
#  * There are no specific primary keys or indexes by default in this database.
#  * Handshape, location, picture and video are set to empty string in some cases
#    rather than NULL. This is to support the iOS app, which is not set up to
#    expect NULL values in these columns
#  * At this stage, the dictionary database is not automatically updated
class DictionarySign < ApplicationRecord
  self.primary_key = :id
  self.table_name = :words

  establish_connection adapter: :sqlite3,
                       database: Rails.root.join("db/nzsl-dictionary.db.sqlite3")

  default_scope -> { where.not(usage: "obscene").or(where(usage: nil)) }
  scope :preview, -> { limit(4) }

  # Use attributes for common sign elements to match the NZSL Share sign schema
  alias_attribute :word, :gloss
  alias_attribute :secondary, :minor

  def video
    DictionarySignAsset.new(super).url
  end

  def self.version
    @version ||= connection.execute("PRAGMA user_version").first["user_version"]
  end
end
