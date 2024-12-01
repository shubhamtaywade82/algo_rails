class MarketAnalysisService < ApplicationService
  def initialize(market_data)
    @market_data = market_data
  end

  def call
    analyze_market
  end

  private

  def analyze_market
    if bullish?
      :bullish
    elsif bearish?
      :bearish
    else
      :sideways
    end
  end

  def bullish?
    # Logic to identify bullish market
    @market_data[:price_change] > 2
  end

  def bearish?
    # Logic to identify bearish market
    @market_data[:price_change] < -2
  end
end
