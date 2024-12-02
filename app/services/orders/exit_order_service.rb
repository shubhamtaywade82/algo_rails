class Orders::ExitOrderService < ApplicationService
  def initialize(position)
    @position = position
  end

  def call
    Dhanhq::Api::Orders.place_order(
      symbol: @position.symbol,
      action: "sell",
      price: current_market_price
    )
    @position.update(status: "closed", exit_price: current_market_price)
  end

  private

  def current_market_price
    # Fetch LTP using DhanHQ API
    Dhanhq::Api::MarketData.fetch_ltp(@position.symbol)
  end
end
