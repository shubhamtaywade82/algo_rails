class CreateInstruments < ActiveRecord::Migration[8.0]
  def change
    create_table :instruments do |t|
      t.integer :security_id, null: false
      t.string :exchange_id, null: false
      t.string :segment, null: false
      t.string :isin
      t.string :instrument
      t.string :underlying_security_id
      t.string :underlying_symbol
      t.string :symbol_name
      t.string :display_name
      t.string :instrument_type
      t.string :series
      t.integer :lot_size
      t.date :expiry_date
      t.decimal :strike_price, precision: 10, scale: 2
      t.decimal :tick_size, precision: 10, scale: 2
      t.string :option_type
      t.string :expiry_flag
      t.string :bracket_flag
      t.string :cover_flag
      t.string :asm_gsm_flag
      t.string :asm_gsm_category
      t.string :buy_sell_indicator
      t.decimal :mtf_leverage, precision: 10, scale: 2

      t.timestamps

      t.index :security_id, unique: true, name: "index_instruments_on_security_id"
    end
  end
end
