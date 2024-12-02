# app/services/orders/strategies/stock_order_strategy.rb
module Orders
  module Strategies
    class StockOrderStrategy < BaseStrategy
      def execute
        direction = alert[:action].downcase
        place_stock_order(direction: direction)
      end

      private

      def place_stock_order(direction:)
        security_id = fetch_security_id(alert[:ticker])
        raise "Security ID not found for #{alert[:ticker]}" unless security_id

        quantity = calculate_quantity(alert[:close])

        Dhanhq::Api::Orders.place_order(
          dhanClientId: ENV["DHAN_CLIENT_ID"],
          transactionType: direction.upcase,
          exchangeSegment: Dhanhq::Constants::NSE,
          productType: Dhanhq::Constants::INTRA,
          orderType: Dhanhq::Constants::MARKET,
          validity: Dhanhq::Constants::DAY,
          securityId: security_id,
          quantity: quantity
        )
      end

      def fetch_security_id(symbol)
        Instrument.find_by(underlying_symbol: symbol)&.security_id
      end

      def calculate_quantity(close_price)
        funds = Dhanhq::Api::Funds.fund_limit["availabelBalance"]
        max_utilization = funds * 0.1 # Utilize 10%
        [ max_utilization / close_price, 1 ].max.to_i
      end
    end
  end
end
