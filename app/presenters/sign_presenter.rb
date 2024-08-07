class SignPresenter < ApplicationPresenter # rubocop:disable Metrics/ClassLength
  presents :sign
  delegate_missing_to :sign
  delegate :to_param, to: :sign

  def dom_id(suffix = nil)
    h.dom_id(sign, suffix)
  end

  def friendly_date
    h.localize(sign.published_at || sign.created_at, format: "%-d %b %Y")
  end

  def fully_processed?
    sign.processed_thumbnails? && sign.processed_videos?
  end

  def moderator_display_name
    I18n.t("signs.#{sign.status}.moderator_display_name")
  end

  def status_name
    user = h.current_user
    key = user&.moderator? && contributor != user ? "moderator_display_name" : "display_name"
    I18n.t("signs.#{sign.status}.#{key}")
  end

  def status_description
    I18n.t("signs.#{sign.status}.description")
  end

  def status_notes
    return unless Pundit.policy(h.current_user, sign).submit?

    I18n.t("signs.#{sign.status}.status_notes")
  end

  def submitted_to_publish?
    sign.submitted? || sign.published? || sign.declined?
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end

  def available_folders(&)
    return [] unless h.user_signed_in?

    @available_folders ||= map_folders_to_memberships(folders, memberships, &)
  end

  def assignable_folder_options
    assignable_folders = available_folders.reject { |_folder, membership| membership.present? }
    h.options_for_select(assignable_folders.map { |f, _m| [f.title, f.id] })
  end

  # AbcSize is disabled because it is the descriptive cache
  # key is what pushes it over - 15.17 / 15 - and a descriptive cache
  # key is preferred to AbcSize compliance here
  def poster_url(size: 1080) # rubocop:disable Metrics/AbcSize
    return fallback_poster_url unless sign.processed_thumbnails? && sign.processed_videos?

    preset = ThumbnailPreset.default.public_send("scale_#{size}").to_h
    preview = video.preview(preset)

    # We do not use the 'sign' instance here, because we want this cache
    # to not expire unless the variation key changes. If we use the sign instance,
    # the cache expires each time the sign is changed at all.
    Rails.cache.fetch([:signs, sign.id, video.blob_id, :poster_url, preview.variation.key]) do
      preview.processed # Ensure the preview is processed
      h.url_for(preview.image)
    end
  end

  def fallback_poster_url
    h.asset_pack_path("static/images/processing.svg")
  end

  def sign_video_sourceset(presets = nil)
    return unless sign.processed_videos?

    h.video_sourceset(sign.video, presets)
  end

  def sign_video_attributes
    class_list = []
    class_list << " has-thumbnails" if sign.processed_thumbnails?
    class_list << " has-video" if sign.processed_videos?

    h.video_attributes(class: class_list, poster: poster_url)
  end

  def overview_intro_text(current_user)
    if current_user.moderator && pending?
      return I18n.t("sign_workflow.#{sign.submitted? ? "publish" : "unpublish"}.confirm")
    end

    "Hey #{current_user.username}, #{action_text(current_user)}"
  end

  def action_text(current_user)
    if sign.contributor == current_user
      "you are the creator of this sign"
    elsif current_user.moderator
      "you are moderating this sign"
    else
      "you are a collaborator on this sign"
    end
  end

  def pending?
    sign.submitted? || sign.unpublish_requested?
  end

  def self.policy_class
    SignPolicy
  end

  def unread_comments?
    user = h.current_user
    return false unless user

    accessible_sign_comments
      .where("sign_comments.created_at > ?", user.created_at)
      .unread_by(user)
      .any?
  end

  def comments_count
    # We use SignComment.where here because sign.sign_comments only includes root-level comments,
    # not replies.
    @comments_count ||= accessible_sign_comments.count
  end

  private

  def accessible_sign_comments
    Pundit
      .policy_scope(h.current_user, SignComment.where(sign:))
      .joins(:sign)
      .where("sign_comments.sign_status = signs.status")
  end

  def map_folders_to_memberships(folders, memberships)
    folders.each_with_object({}) do |folder, acc|
      membership = memberships.find { |mem| mem.folder_id == folder.id }
      yield folder, membership if block_given?

      acc[folder] = membership
    end
  end

  def folders
    @folders ||= Pundit.policy_scope(h.current_user, Folder)
                       .includes(collaborations: :collaborator)
                       .where(collaborations: { collaborator_id: h.current_user.id })
  end

  def memberships
    @memberships ||= sign.folder_memberships.includes(:folder).where(folder_id: @folders.map(&:id))
  end
end
