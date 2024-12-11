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
      order_details = fetch_order_details(order_response["orderId"])

      return unless order_details

      TrailingStopLossService.new(
        order_id: order_details["orderId"],
        security_id: order_details["securityId"],
        transaction_type: order_details["transactionType"],
        trailing_stop_loss_percentage: alert[:trailing_stop_loss]
      ).call
      # Rails.logger.debug("TrailingStopLossService arguments: #{{
      #   order_id: order_response["orderId"],
      #   security_id: order_response["securityId"],
      #   transaction_type: order_response["transactionType"],
      #   trailing_stop_loss_percentage: alert[:trailing_stop_loss]
      # }}")

      # TrailingStopLossService.new(
      #   order_id: order_response["orderId"],
      #   security_id: order_response["securityId"],
      #   transaction_type: order_response["transactionType"],
      #   trailing_stop_loss_percentage: alert[:trailing_stop_loss]
      # ).call
    end

    def fetch_order_details(order_id)
      response = Dhanhq::Api::Orders.get_order_by_id(order_id)
      raise "Failed to fetch order details for order ID #{order_id}" unless response

      response
    rescue StandardError => e
      Rails.logger.error("Error fetching order details: #{e.message}")
      nil
    end
  end
end
