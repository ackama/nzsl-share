class SignPresenter < ApplicationPresenter
  presents :sign
  delegate :id, :english, :contributor, :agree_count, :disagree_count, to: :sign

  def dom_id(suffix=nil)
    h.dom_id(sign, suffix)
  end

  def friendly_date
    h.localize(sign.published_at || sign.created_at, format: "%-d %B %Y")
  end

  def available_folders
    @folders ||= h.current_user_folders
    @memberships ||= sign.folder_memberships.includes(:folder).where(folder_id: @folders.map(&:id))

    @folders.each_with_object({}) do |folder, acc|
      membership = @memberships.find { |mem| mem.folder_id == folder.id }
      yield folder, membership if block_given?

      acc[folder] = membership
    end
  end

  def assignable_folder_options
    assignable_folders = available_folders.reject { |_folder, membership| membership.present? }
    h.options_for_select(assignable_folders.map { |f, _m| [f.title, f.id] })
  end
end
