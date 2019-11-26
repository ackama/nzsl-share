require "administrate/base_dashboard"

class ApprovedUserApplicationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    first_name: Field::String,
    last_name: Field::String,
    deaf: Field::Boolean,
    nzsl_first_language: Field::Boolean,
    age_bracket: Field::String,
    location: Field::String,
    gender: Field::String,
    ethnicity: Field::String,
    language_roles: Field::String,
    subject_expertise: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    user
    first_name
    last_name
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    user
    first_name
    last_name
    deaf
    nzsl_first_language
    age_bracket
    location
    gender
    ethnicity
    language_roles
    subject_expertise
    created_at
    updated_at
    status
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

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
    pending: ->(resources) { resources.submitted },
    accepted: ->(resources) { resources.accepted },
    declined: ->(resources) { resources.declined }
  }.freeze

  # Overwrite this method to customize how approved user applications are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(application)
    "Approved Member Application for '#{application.user.username}'"
  end
end
