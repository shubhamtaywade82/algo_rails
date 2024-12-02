module Orders
  module Strategies
    class OptionOrderStrategy < BaseStrategy
      def execute
        direction = alert[:action].downcase
        place_option_order(direction: direction)
      end

      private

      def place_option_order(direction:)
        Dhanhq::Api::Orders.place_order(
          security_id: fetch_security_id(alert[:ticker]),
          exchange_segment: Dhanhq::Constants::NSE_FNO,
          transaction_type: direction.upcase,
          order_type: Dhanhq::Constants::MARKET,
          product_type: Dhanhq::Constants::INTRA,
          quantity: calculate_quantity
        )
      end

      def fetch_security_id(ticker)
        Instrument.find_by(symbol_name: ticker)&.security_id
      end

      def calculate_quantity
        # Add logic for determining quantity
        1
      end
    end
  end
end
