class SignPresenter < ApplicationPresenter
  presents :sign
  delegate :id, :english, :contributor, :agree_count, :disagree_count, to: :sign

  def dom_id(suffix=nil)
    h.dom_id(sign, suffix)
  end

  def friendly_date
    h.localize(sign.published_at || sign.created_at, format: "%-d %B %Y")
  end
end
