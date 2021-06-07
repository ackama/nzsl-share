require "administrate/base_dashboard"

class SignDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    video: Field::String.with_options(searchable: false),
    word: Field::String,
    status: Field::String,
    submitted_at: Field::DateTime,
    contributor_email: Field::BelongsTo.with_options(
      class_name: "User",
      foreign_key: :contributor_id,
      source: :contributor,
      searchable: true,
      searchable_fields: [:email]
    ),
    contributor_username: Field::BelongsTo.with_options(
      class_name: "User",
      foreign_key: :contributor_id,
      source: :contributor,
      searchable: true,
      searchable_fields: [:username]
    )
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    video
    word
    status
    submitted_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    video
    word
    status
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    word
    status
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {
    pending: ->(resources) { resources.unpublish_requested.or(resources.submitted) },
    published: ->(resources) { resources.published },
    archived: ->(resources) { resources.archived }
  }.freeze

  # Overwrite this method to customize how signs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(sign)
  #   "Sign ##{sign.id}"
  # end
end
