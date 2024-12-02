require "csv"
require "open-uri"

class InstrumentImporter
  CSV_URL = "https://images.dhan.co/api-data/api-scrip-master-detailed.csv"

  def self.import_from_csv
    csv_data = URI.open(CSV_URL).read
    csv = CSV.parse(csv_data, headers: true)

    csv.each do |row|
      date = parse_date(row["SM_EXPIRY_DATE"])
      if row["EXCH_ID"] == "NSE"
        next if date ? date < Date.today : false

        Instrument.find_or_initialize_by(security_id: row["SECURITY_ID"]).tap do |instrument|
          instrument.exchange_id = row["EXCH_ID"]
          instrument.segment = row["SEGMENT"]
          instrument.isin = row["ISIN"]
          instrument.instrument = row["INSTRUMENT"]
          instrument.underlying_security_id = row["UNDERLYING_SECURITY_ID"]
          instrument.underlying_symbol = row["UNDERLYING_SYMBOL"]
          instrument.symbol_name = row["SYMBOL_NAME"]
          instrument.display_name = row["DISPLAY_NAME"]
          instrument.instrument_type = row["INSTRUMENT_TYPE"]
          instrument.series = row["SERIES"]
          instrument.lot_size = row["LOT_SIZE"].to_i
          instrument.expiry_date = parse_date(row["SM_EXPIRY_DATE"])
          instrument.strike_price = row["STRIKE_PRICE"].to_d
          instrument.tick_size = row["TICK_SIZE"].to_d
          instrument.option_type = row["OPTION_TYPE"]
          instrument.expiry_flag = row["EXPIRY_FLAG"]
          instrument.bracket_flag = row["BRACKET_FLAG"]
          instrument.cover_flag = row["COVER_FLAG"]
          instrument.asm_gsm_flag = row["ASM_GSM_FLAG"]
          instrument.asm_gsm_category = row["ASM_GSM_CATEGORY"]
          instrument.buy_sell_indicator = row["BUY_SELL_INDICATOR"]
          instrument.mtf_leverage = row["MTF_LEVERAGE"].to_d

          instrument.save!
          pp "Instrument #{instrument.exchange_id} #{instrument.security_id} imported successfully."
        end
      end
    end
  end

  def self.parse_date(date_str)
    Date.parse(date_str) rescue nil
  end
end
