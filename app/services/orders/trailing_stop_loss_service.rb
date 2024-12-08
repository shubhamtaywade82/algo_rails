class TrailingStopLossService < ApplicationService
  def initialize(order_id:, security_id:, transaction_type:, trailing_stop_loss_percentage:)
    @order_id = order_id
    @security_id = security_id
    @transaction_type = transaction_type.downcase
    @trailing_stop_loss_percentage = trailing_stop_loss_percentage.to_f / 100.0
    @client = Dhanhq::Api::Orders
  end

  def call
    monitor_price
  end

  private

  def monitor_price
    loop do
      current_price = fetch_market_price

      if current_price.nil?
        Rails.logger.warn("Market price unavailable. Skipping stop-loss update for Order #{@order_id}.")
        sleep(60) # Wait longer if market price is unavailable
        next
      end

      if should_update_stop_loss?(current_price)
        new_trigger_price = calculate_new_trigger_price(current_price)
        update_stop_loss(new_trigger_price)
      end

      sleep(30) # Poll every 30 seconds
    end
  end

  def fetch_market_price
    begin
      # Simulating LTP fetch due to missing Data API subscription
      instrument = Instrument.find_by(security_id: @security_id)
      raise "Instrument not found for Security ID #{@security_id}" unless instrument

      # Using a simple heuristic to simulate price movement
      simulated_price = instrument.last_known_price * (1 + random_price_variation)
      Rails.logger.info("Simulated market price for Security ID #{@security_id}: #{simulated_price}")
      simulated_price
    rescue StandardError => e
      Rails.logger.error("Error fetching market price: #{e.message}")
      nil
    end
  end

  def random_price_variation
    # Simulate market price fluctuation (e.g., ±0.5%)
    (rand(-5..5) / 1000.0)
  end

  def calculate_new_trigger_price(current_price)
    if @transaction_type == "buy"
      current_price * (1 - @trailing_stop_loss_percentage)
    else
      current_price * (1 + @trailing_stop_loss_percentage)
    end
  end

  def should_update_stop_loss?(current_price)
    current_trigger_price = fetch_current_trigger_price
    return false unless current_trigger_price

    new_trigger_price = calculate_new_trigger_price(current_price)
    new_trigger_price > current_trigger_price
  end

  def fetch_current_trigger_price
    # Fetch the current stop-loss trigger price using the API
    order_details = @client.get_order_by_id(@order_id)
    order_details["triggerPrice"].to_f
  rescue StandardError => e
    Rails.logger.error("Error fetching order details: #{e.message}")
    nil
  end

  def update_stop_loss(new_trigger_price)
    @client.modify_order(@order_id, {
      orderType: "STOP_LOSS",
      triggerPrice: new_trigger_price
    })
    Rails.logger.info("Trailing stop-loss updated to #{new_trigger_price}")
  rescue StandardError => e
    Rails.logger.error("Error updating stop-loss: #{e.message}")
  end
end
