class SignPresenter < ApplicationPresenter
  presents :sign
  delegate :id, :word, :contributor, :agree_count, :disagree_count, :to_param, to: :sign

  def dom_id(suffix=nil)
    h.dom_id(sign, suffix)
  end

  def friendly_date
    h.localize(sign.published_at || sign.created_at, format: "%-d %B %Y")
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

  private

  def map_folders_to_memberships(folders, memberships)
    folders.each_with_object({}) do |folder, acc|
      membership = memberships.find { |mem| mem.folder_id == folder.id }
      yield folder, membership if block_given?

      acc[folder] = membership
    end
  end
end
