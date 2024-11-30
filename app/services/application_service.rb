class ApplicationService
  class << self
    # Calls the service with the given arguments
    #
    # @param args [Array] Arguments to be passed to the service initializer
    # @return [Object] Result of the `call` method in the service
    #
    # @example
    #   MyService.call(arg1, arg2)
    def call(*args, &block)
      new(*args, &block).call
    end
  end
end
