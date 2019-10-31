module PresentersHelper
  def present(object, klass=nil)
    presenter = if !object.is_a?(ApplicationPresenter)
                  klass ||= "#{object.class}Presenter".constantize
                  klass.new(object, is_a?(ActionController::Base) ? view_context : self)
                else
                  object
                end

    yield presenter if block_given?
    presenter
  end
end
