class AttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    return if record.send(attribute).attached?

    record.errors.add(attribute, :blank)
  end
end
