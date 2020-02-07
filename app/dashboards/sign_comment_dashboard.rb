require "administrate/base_dashboard"

class SignCommentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    sign: Field::BelongsTo,
    folder: Field::BelongsTo,
    replies: Field::HasMany.with_options(class_name: "SignComment"),
    reports: Field::HasMany.with_options(class_name: "CommentReport"),
    video_attachment: Field::HasOne,
    video_blob: Field::HasOne,
    id: Field::Number,
    parent_id: Field::Number,
    comment: Field::Text,
    sign_status: Field::Text,
    display: Field::Boolean,
    anonymous: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    user
    sign
    folder
    replies
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    user
    sign
    folder
    replies
    reports
    video_attachment
    video_blob
    id
    parent_id
    comment
    sign_status
    display
    anonymous
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    user
    sign
    folder
    replies
    reports
    video_attachment
    video_blob
    parent_id
    comment
    sign_status
    display
    anonymous
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
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how sign comments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(sign_comment)
  #   "SignComment ##{sign_comment.id}"
  # end
end
