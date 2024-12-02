class Orders::PlaceOrderService < ApplicationService
  def initialize(symbol:, action:, price:)
    @symbol = symbol
    @action = action
    @price = price
  end

  def call
    Dhanhq::Api::Orders.place_order(
      symbol: @symbol,
      action: @action,
      price: @price
    )
  end
end
