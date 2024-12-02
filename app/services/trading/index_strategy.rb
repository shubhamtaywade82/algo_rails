module Trading
  class IndexStrategy < BaseStrategy
    def valid_alert?
      %w[buy sell].include?(payload["action"].downcase) &&
        payload["market"].casecmp("index").zero?
    end

    def place_order
      Rails.logger.info "Placing index options order for #{payload['ticker']}"
      option_type = payload["action"].casecmp("buy").zero? ? "CALL" : "PUT"
      spot_price = dhan_api.get_spot_price(payload["ticker"], payload["exchange"])
      strike_price = calculate_strike_price(spot_price, "ATM")

      dhan_api.place_order(
        dhanClientId: ENV["DHAN_CLIENT_ID"],
        transactionType: "BUY",
        exchangeSegment: "NSE_FNO",
        productType: "INTRADAY",
        orderType: "MARKET",
        validity: "DAY",
        securityId: dhan_api.get_option_security_id(payload["ticker"], strike_price, option_type),
        quantity: calculate_quantity(payload["close"]),
        price: payload["close"]
      )
    end

    private

    def calculate_strike_price(spot_price, type)
      case type
      when "ATM"
        (spot_price / 50).round * 50
      when "ITM"
        ((spot_price - 50) / 50).round * 50
      when "OTM"
        ((spot_price + 50) / 50).round * 50
      end
    end

    def calculate_quantity(price)
      available_funds = dhan_api.get_available_funds
      (available_funds / price).to_i
    end
  end
end
