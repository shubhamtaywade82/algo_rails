class StrategyExecutionService < ApplicationService
  def initialize(strategy, market_data)
    @strategy = strategy
    @market_data = market_data
    @orders_service = OrdersService.new
  end

  def call
    execute_strategy
  end

  private

  def execute_strategy
    case @strategy.market_type
    when "bullish"
      execute_bullish_strategy
    when "bearish"
      execute_bearish_strategy
    when "sideways"
      execute_sideways_strategy
    else
      { error: "Unknown market type" }
    end
  end

  def execute_bullish_strategy
    # Example: Place buy order
    @orders_service.place_order({
      dhanClientId: Dhanhq.configuration.client_id,
      transactionType: "BUY",
      exchangeSegment: "NSE_EQ",
      productType: "INTRADAY",
      orderType: "MARKET",
      validity: "DAY",
      securityId: @market_data[:security_id],
      quantity: 10
    })
  end

  def execute_bearish_strategy
    # Example: Place sell order
    @orders_service.place_order({
      dhanClientId: Dhanhq.configuration.client_id,
      transactionType: "SELL",
      exchangeSegment: "NSE_EQ",
      productType: "INTRADAY",
      orderType: "MARKET",
      validity: "DAY",
      securityId: @market_data[:security_id],
      quantity: 10
    })
  end

  def execute_sideways_strategy
    # Logic for sideways trading
  end
end
