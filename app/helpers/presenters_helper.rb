module PresentersHelper
  def present(object, klass = nil)
    presenter = if object.is_a?(ApplicationPresenter)
                  object
                else
                  klass ||= "#{object.class}Presenter".constantize
                  klass.new(object, is_a?(ActionController::Base) ? view_context : self)
                end

    yield presenter if block_given?
    presenter
  end

  def present_collection(collection, klass = nil)
    collection.map { |item| present(item, klass) }
  end
end
