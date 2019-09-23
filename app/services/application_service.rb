class ApplicationService
  class Results
    attr_accessor :data
  end

  class << self
    def call(*args, &block)
      new(*args, &block).process
    end

    def new_results
      Results.new
    end
  end
end
