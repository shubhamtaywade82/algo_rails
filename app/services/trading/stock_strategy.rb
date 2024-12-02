module Trading
  class StockStrategy < BaseStrategy
    def valid_alert?
      %w[buy sell].include?(payload["action"].downcase) &&
        payload["market"].casecmp("stock").zero?
    end

    def place_order
      Rails.logger.info "Placing stock order for #{payload['ticker']}"
      dhan_api.place_order(
        dhanClientId: ENV["DHAN_CLIENT_ID"],
        transactionType: payload["action"].upcase,
        exchangeSegment: payload["exchange"],
        productType: "INTRADAY",
        orderType: "MARKET",
        validity: "DAY",
        securityId: dhan_api.get_security_id(payload["ticker"]),
        quantity: calculate_quantity(payload["close"]),
        price: payload["close"]
      )
    end

    private

    def calculate_quantity(price)
      available_funds = dhan_api.get_available_funds
      (available_funds / price).to_i
    end
  end
end
