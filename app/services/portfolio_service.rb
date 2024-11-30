# app/services/portfolio_service.rb

class PortfolioService < ApplicationService
  def initialize(action, params = {})
    @client = Dhanhq::Api::Portfolio
    @action = action
    @params = params
  end

  def call
    case @action
    when :holdings
      fetch_holdings
    when :positions
      fetch_positions
    else
      { error: "Unknown action: #{@action}" }
    end
  end

  private

  def fetch_holdings
    @client.holdings
  rescue StandardError => e
    handle_error(e)
  end

  def fetch_positions
    @client.positions
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(error)
    Rails.logger.error("Dhan API Error: #{error.message}")
    { error: error.message }
  end
end
