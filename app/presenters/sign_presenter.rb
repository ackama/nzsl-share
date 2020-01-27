class SignPresenter < ApplicationPresenter
  presents :sign
  delegate_missing_to :sign
  delegate :to_param, to: :sign

  def dom_id(suffix=nil)
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
    return unless sign.status == "personal"

    I18n.t("signs.#{sign.status}.status_notes")
  end

  def submitted_to_publish?
    sign.submitted? || sign.published? || sign.declined?
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end

  def available_folders(&block)
    return [] unless h.user_signed_in?

    @folders ||= h.policy_scope(Folder).where(collaborations: { collaborator_id: h.current_user.id })
    @memberships ||= sign.folder_memberships.includes(:folder).where(folder_id: @folders.map(&:id))
    map_folders_to_memberships(@folders, @memberships, &block)
  end

  def assignable_folder_options
    assignable_folders = available_folders.reject { |_folder, membership| membership.present? }
    h.options_for_select(assignable_folders.map { |f, _m| [f.title, f.id] })
  end

  def poster_url(size: 1080)
    return h.asset_pack_path("media/images/processing.svg") unless sign.processed_thumbnails?

    preset = ThumbnailPreset.default.public_send("scale_#{size}").to_h
    video.preview(preset).processed.service_url
  end

  def sign_video_sourceset(presets=nil)
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

  private

  def map_folders_to_memberships(folders, memberships)
    folders.each_with_object({}) do |folder, acc|
      membership = memberships.find { |mem| mem.folder_id == folder.id }
      yield folder, membership if block_given?

      acc[folder] = membership
    end
  end
end
