class ApplicationService
  class Results
    attr_accessor :data
  end

  class << self
    def call(*args, &block)
      new(*args, &block)
    end
  end
end
