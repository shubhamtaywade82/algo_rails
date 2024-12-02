class Alerts::ProcessTradingAlertService < ApplicationService
  def initialize(alert)
    @alert = alert
  end

  def call
    return handle_position_change if position_changed?

    case @alert.action.downcase
    when "buy"
      process_buy_order
    when "sell"
      process_sell_order
    else
      @alert.update(status: "failed", error_message: "Invalid action")
    end
  end

  private

  def handle_position_change
    if @alert.current_position == "flat" && @alert.previous_position == "long"
      process_sell_order
    elsif @alert.current_position == "flat" && @alert.previous_position == "short"
      process_buy_order
    else
      @alert.update(status: "failed", error_message: "Unhandled position change")
    end
  end

  def position_changed?
    @alert.previous_position != @alert.current_position
  end

  def process_buy_order
    if sufficient_funds? && no_conflicting_positions?
      Orders::PlaceOrderService.call(
        symbol: @alert.ticker,
        action: "buy",
        price: @alert.close
      )
      @alert.update(status: "processed")
    else
      @alert.update(status: "failed", error_message: "Insufficient funds or conflicting positions")
    end
  end

  def process_sell_order
    position = Position.find_by(symbol: @alert.ticker, status: "open")
    if position
      Orders::ExitOrderService.call(position)
      @alert.update(status: "processed")
    else
      @alert.update(status: "failed", error_message: "No matching open position")
    end
  end

  def sufficient_funds?
    # Check funds via DhanHQ API
    Dhanhq::Api::Funds.available_balance > @alert.close
  end

  def no_conflicting_positions?
    # Ensure no open positions for the same symbol
    Position.where(symbol: @alert.ticker, status: "open").none?
  end
end
