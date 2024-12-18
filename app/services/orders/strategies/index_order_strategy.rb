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

        debugger

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
        funds = Dhanhq::Api::Funds.fund_limit["availabelBalance"]
        max_utilization = funds * 0.3
        lot_size = Instrument.find_by(symbol_name: "NIFTY").lot_size
        [ max_utilization / (strike_price * lot_size), 1 ].max.to_i
      end

      def place_option_order(strike_price:, option_type:, direction:, quantity:)
        instrument = fetch_instrument(strike_price, option_type)

        Dhanhq::Api::Orders.place_order(
          dhanClientId: ENV["DHAN_CLIENT_ID"],
          transactionType: direction.upcase,
          exchangeSegment: Dhanhq::Constants::NSE_FNO,
          productType: Dhanhq::Constants::INTRA,
          orderType: Dhanhq::Constants::MARKET,
          validity: Dhanhq::Constants::DAY,
          securityId: instrument.security_id.to_s,
          quantity: quantity * instrument.lot_size
        )
      end

      def fetch_instrument(strike_price, option_type)
        expiry_type = determine_expiry_type(alert[:expiry_flag])

        instrument = Instrument.where(
          underlying_symbol: "NIFTY",
          strike_price: strike_price,
          option_type: option_type.upcase,
          expiry_flag: expiry_type,
          expiry_date: nearest_expiry_date(expiry_type)
        ).order(:expiry_date).first

        raise "Security ID not found for strike price #{strike_price}, option type #{option_type}, expiry type #{expiry_type}" unless instrument

        instrument
      end

      # Determine if the expiry is weekly or monthly
      def determine_expiry_type(expiry_flag)
        case expiry_flag&.upcase
        when "W"
          "W" # Weekly
        when "M", nil
          "M" # Monthly as default
        else
          raise "Unsupported expiry flag: #{expiry_flag}"
        end
      end

      # Fetch the nearest expiry date for the given expiry type
      def nearest_expiry_date(expiry_type)
        Instrument.where(
          underlying_symbol: "NIFTY",
          expiry_flag: expiry_type
        ).where("expiry_date >= ?", Date.today)
        .order(:expiry_date)
        .limit(1)
        .pluck(:expiry_date)
        .first
      end
    end
  end
end
