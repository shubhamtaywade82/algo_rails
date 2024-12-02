# app/services/orders/strategies/index_order_strategy.rb
module Orders
  module Strategies
    class IndexOrderStrategy < BaseStrategy
      ITM_OFFSET = -1
      ATM_OFFSET = 0

      def execute
        direction = alert[:action].downcase
        option_type = direction == "buy" ? "CE" : "PE"

        strike_price = calculate_strike_price(alert[:close], offset: ATM_OFFSET)
        quantity = calculate_quantity(strike_price)

        place_option_order(
          strike_price: strike_price,
          option_type: option_type,
          direction: direction,
          quantity: quantity
        )
      end

      private

      def calculate_strike_price(close_price, offset:)
        step = 50 # NIFTY options have 50-point intervals
        base_strike = (close_price / step).round * step
        base_strike + (offset * step)
      end

      def calculate_quantity(strike_price)
        funds = Dhanhq::Api::Funds.fund_limit["available_balance"]
        max_utilization = funds * 0.3
        lot_size = Instrument.find_by(symbol_name: "NIFTY").lot_size
        [ max_utilization / (strike_price * lot_size), 1 ].max.to_i
      end

      def place_option_order(strike_price:, option_type:, direction:, quantity:)
        security_id = fetch_security_id(strike_price, option_type)

        Dhanhq::Api::Orders.place_order(
          dhanClientId: ENV["DHAN_CLIENT_ID"],
          transactionType: direction.upcase,
          exchangeSegment: Dhanhq::Constants::NSE_FNO,
          productType: Dhanhq::Constants::INTRA,
          orderType: Dhanhq::Constants::MARKET,
          validity: Dhanhq::Constants::DAY,
          securityId: security_id,
          quantity: quantity
        )
      end

      def fetch_security_id(strike_price, option_type)
        Instrument.find_by(symbol_name: "NIFTY#{strike_price}#{option_type}")&.security_id ||
          raise("Security ID not found for strike price #{strike_price} #{option_type}")
      end
    end
  end
end
