require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    email: Field::String,
    username: Field::String,
    bio: Field::String,
    administrator: Field::Boolean.with_options(searchable: false),
    moderator: Field::Boolean.with_options(searchable: false),
    approved: Field::Boolean.with_options(searchable: false),
    validator: Field::Boolean.with_options(searchable: false),
    contribution_limit: Field::Number.with_options(searchable: false),
    signs: Field::HasMany,
    approved_user_application: Field::BelongsTo
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    username
    email
    signs
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    username
    email
    bio
    contribution_limit
    administrator
    moderator
    approved
    approved_user_application
    validator
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    administrator
    moderator
    approved
    validator
    contribution_limit
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
    administrator: ->(resources) { resources.where(administrator: true) },
    moderator: ->(resources) { resources.where(moderator: true) },
    validator: ->(resources) { resources.where(validator: true) },
    approved: ->(resources) { resources.where(approved: true) },
    basic: ->(resources) { resources.where(administrator: false, validator: false, moderator: false, approved: false) },
    unconfirmed: ->(resources) { resources.unconfirmed }
  }.freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    "'#{user.username}'"
  end
end
