# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_01_073700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.string "ticker"
    t.decimal "close", precision: 15, scale: 2
    t.datetime "time"
    t.integer "volume"
    t.string "action"
    t.string "market"
    t.string "exchange"
    t.string "error_message"
    t.string "current_position"
    t.string "previous_position"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instruments", force: :cascade do |t|
    t.integer "security_id", null: false
    t.string "exchange_id", null: false
    t.string "segment", null: false
    t.string "isin"
    t.string "instrument"
    t.string "underlying_security_id"
    t.string "underlying_symbol"
    t.string "symbol_name"
    t.string "display_name"
    t.string "instrument_type"
    t.string "series"
    t.integer "lot_size"
    t.date "expiry_date"
    t.decimal "strike_price", precision: 10, scale: 2
    t.decimal "tick_size", precision: 10, scale: 2
    t.string "option_type"
    t.string "expiry_flag"
    t.string "bracket_flag"
    t.string "cover_flag"
    t.string "asm_gsm_flag"
    t.string "asm_gsm_category"
    t.string "buy_sell_indicator"
    t.decimal "mtf_leverage", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_id"], name: "index_instruments_on_security_id", unique: true
  end

  create_table "strategies", force: :cascade do |t|
    t.string "name"
    t.string "market_type"
    t.json "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
