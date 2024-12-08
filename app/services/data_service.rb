class DataService
  include DataApiHelper

  def fetch_ltp(symbols)
    return { error: "Data APIs are disabled" } unless data_api_enabled?

    Dhanhq::Api::Marketfeed.ltp(symbols: symbols)
  end

  def fetch_historical_data(symbol, interval, from, to)
    return { error: "Data APIs are disabled" } unless data_api_enabled?

    Dhanhq::Api::HistoricalData.fetch(symbol: symbol, interval: interval, from: from, to: to)
  end
end
