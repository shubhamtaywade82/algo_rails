module Alerts
  class ProcessTradingAlertService < ApplicationService
    def initialize(alert)
      @alert = alert
    end

    def call
      strategy = determine_strategy
      strategy.execute
      alert.update(status: "processed")
    rescue StandardError => e
      alert.update(status: "failed", error_message: e.message)
      Rails.logger.error("Failed to process alert: #{e.message}")
    end

    private

    attr_reader :alert

    def determine_strategy
      case alert[:market].upcase
      when "INDEX"
        Orders::Strategies::IndexOrderStrategy.new(alert)
      when "STOCK"
        Orders::Strategies::StockOrderStrategy.new(alert)
      else
        raise NotImplementedError, "No strategy defined for market type: #{alert[:market]}"
      end
    end
  end
end
