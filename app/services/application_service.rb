class ApplicationService
  class << self
    def call(**args, &block)
      new(**args, &block).process
    end
  end
end
