module Alerts
  class ProcessTradingAlertService < ApplicationService
    def initialize(alert)
      @alert = alert
    end

    def call
      strategy = determine_strategy
      order_response = strategy.execute

      if order_response["orderId"]
        setup_trailing_stop_loss(order_response)
      end

      alert.update(status: "processed")
    rescue StandardError => e
      alert.update(status: "failed", error_message: e.message)
      Rails.logger.error("Failed to process alert: #{e.message}")
    end

    private

    attr_reader :alert

    def determine_strategy
      case alert[:market].upcase
      when "INDEX", "OPTION"
        Orders::Strategies::UnifiedOptionsStrategy.new(alert)
      when "STOCK"
        Orders::Strategies::StockOrderStrategy.new(alert)
      else
        raise NotImplementedError, "No strategy defined for market type: #{alert[:market]}"
      end
    end

    def setup_trailing_stop_loss(order_response)
      TrailingStopLossService.call(
        order_id: order_response["orderId"],
        security_id: order_response["securityId"],
        transaction_type: order_response["transactionType"],
        trailing_stop_loss_percentage: alert[:trailing_stop_loss]
      )
    end
  end
end
