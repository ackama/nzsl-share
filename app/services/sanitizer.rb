# frozen_string_literal: true

class Sanitizer
  def self.sanitize(input="")
    input = ActionController::Base.helpers.sanitize(input)
    input = ActionController::Base.helpers.strip_links(input)
    input = ActionController::Base.helpers.strip_tags(input)
    input
  end
end
