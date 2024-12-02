module Trading
  class BaseStrategy
    attr_reader :payload, :dhan_api

    def initialize(payload)
      @payload = payload
      @dhan_api = DhanApi.instance
    end

    # Template method defining the process
    def execute
      if valid_alert?
        place_order
        log_trade
      else
        Rails.logger.warn "Invalid alert: #{payload.inspect}"
      end
    end

    # Placeholder methods to be implemented by subclasses
    def valid_alert?
      raise NotImplementedError, "Subclasses must implement this method"
    end

    def place_order
      raise NotImplementedError, "Subclasses must implement this method"
    end

    def log_trade
      AlertLogger.log(payload)
    end
  end
end
