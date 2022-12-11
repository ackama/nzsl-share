# frozen_string_literal: true

class DictionarySearchService < SimpleDelegator
  def initialize(search:, relation:)
    if relation.model == FreelexSign
      super(FreelexSearchService.new(search: search, relation: relation))
    else
      super(SignbankSearchService.new(search: search, relation: relation))
    end
  end
end
