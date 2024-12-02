# app/services/orders/order_placement_service.rb
module Orders
  class OrderPlacementService < ApplicationService
    STRATEGY_MAP = {
      "INDEX" => Strategies::IndexOrderStrategy,
      "STOCK" => Strategies::StockOrderStrategy,
      "OPTION" => Strategies::OptionOrderStrategy
    }.freeze

    def initialize(alert)
      @alert = alert
    end

    def call
      strategy_class = STRATEGY_MAP[alert[:market]]
      raise "Unsupported market type: #{alert[:market]}" unless strategy_class

      strategy = strategy_class.new(alert)
      strategy.execute
    rescue StandardError => e
      Rails.logger.error("Failed to place order: #{e.message}")
    end

    private

    attr_reader :alert
  end
end
