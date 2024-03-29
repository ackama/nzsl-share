ActionView::Base.field_error_proc = proc do |html_tag|
  next html_tag if html_tag.include?("<label") # Don't style labels

  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index + 7, "invalid "
  else
    html_tag.insert html_tag.index(">"), ' class="invalid"'.html_safe
  end
end

class ActionView::Helpers::FormBuilder
  def error(attribute)
    return unless object.errors[attribute].any?

    @template.content_tag(:p, object.errors[attribute].join(", "), class: "form-error show")
  end
end
