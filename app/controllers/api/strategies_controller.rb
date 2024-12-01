module Api
  class StrategiesController < ApplicationController
    def index
      strategies = Strategy.all
      render json: strategies
    end

    def execute
      strategy = Strategy.find(params[:id])
      market_data = fetch_market_data
      result = StrategyExecutionService.call(strategy, market_data)
      render json: result
    end

    private

    def fetch_market_data
      # Fetch real-time market data from TradingView or other services
      {
        security_id: "12345",
        price_change: 3.0
      }
    end
  end
end
