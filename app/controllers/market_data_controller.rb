class MarketDataController < ApplicationController
  def ltp
    symbols = params[:symbols]
    result = DataService.new.fetch_ltp(symbols)
    render json: result
  end
end
