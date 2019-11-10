class SignPresenter < ApplicationPresenter
  presents :sign
  delegate :id, :word, :maori, :secondary, :contributor, :agree_count,
           :disagree_count, :topic, :video, :description,
           :errors, :to_model, :contributor_id, :conditions_accepted,
           :status, :to_param, to: :sign

  def dom_id(suffix=nil)
    h.dom_id(sign, suffix)
  end

  def friendly_date
    h.localize(sign.published_at || sign.created_at, format: "%-d %b %Y")
  end

  def fully_processed?
    sign.processed_thumbnails? && sign.processed_videos?
  end

  def status_name
    I18n.t("signs.#{sign.status}.display_name")
  end

  def status_description
    I18n.t("signs.#{sign.status}.description")
  end

  def edit_status_instructions
    return unless sign.status == "personal"

    I18n.t("signs.#{sign.status}.edit_status_instructions")
  end

  def submitted_to_publish?
    sign.submitted? || sign.published? || sign.declined?
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end

  def available_folders(&block)
    return [] unless h.user_signed_in?

    @folders ||= h.current_user.folders.in_order
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

  def sign_video_source(preset)
    h.content_tag(:source, nil, src: h.sign_video_path(sign_id: sign.id, preset: preset))
  end

  def sign_video_sourceset(presets=%w[1080p 720p 360p])
    return unless sign.processed_videos?

    h.safe_join(presets.map { |preset| sign_video_source(preset) })
  end

  def sign_video_attributes
    class_list = ["sign-video"]
    class_list << " has-thumbnails" if sign.processed_thumbnails?
    class_list << " has-video" if sign.processed_videos?

    {
      class: class_list.join(" "),
      controls: true,
      controlslist: "nodownload",
      preload: false,
      muted: true,
      poster: poster_url
    }
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
