class FreelexSignPresenter < ApplicationPresenter
  presents :sign
  delegate_missing_to :sign

  def url
    "https://nzsl.nz/signs/#{sign.headword_id}"
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end
end
