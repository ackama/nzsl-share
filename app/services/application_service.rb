class ApplicationService
  class Results
    attr_writer :data

    def data
      return @data.flatten! if @data.respond_to?(:flatten!)

      @data
    end
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
