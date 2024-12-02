require 'rails_helper'

RSpec.describe "TradingView Webhooks", type: :request do
  let(:valid_headers) { { "Content-Type" => "application/json" } }

  describe "POST /api/v1/webhooks/tradingview" do
    let(:valid_index_buy_payload) do
      {
        webhook: {
          ticker: "NIFTY",
          close: "18500",
          time: Time.now.utc,
          action: "buy",
          market: "INDEX",
          exchange: "NSE",
          volume: 0,
          current_position: "long",
          previous_position: "flat"
        }
      }
    end

    let(:valid_stock_sell_payload) do
      {
        webhook: {
          ticker: "INDIANB",
          close: "569.75",
          time: Time.now.utc,
          action: "sell",
          market: "STOCK",
          exchange: "NSE",
          volume: 57,
          current_position: "short",
          previous_position: "long"
        }
      }
    end

    let(:invalid_payload) do
      {
        webhook: {
          ticker: nil,
          close: nil,
          time: Time.now.utc,
          action: "buy",
          market: "INDEX",
          exchange: "NSE",
          current_position: "long",
          previous_position: "flat"
        }
      }
    end

    context "with valid INDEX buy alert" do
      it "processes the alert successfully and returns status 200" do
        post "/api/v1/webhooks/tradingview", params: valid_index_buy_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "Alert processed successfully")
      end
    end

    context "with valid STOCK sell alert" do
      it "processes the alert successfully and returns status 200" do
        post "/api/v1/webhooks/tradingview", params: valid_stock_sell_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "Alert processed successfully")
      end
    end

    context "with invalid payload" do
      it "returns status 422 with an error message" do
        post "/api/v1/webhooks/tradingview", params: invalid_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Failed to save alert")
      end
    end

    context "with delayed alert" do
      let(:delayed_payload) do
        {
          webhook: {
            ticker: "NIFTY",
            close: "18500",
            time: 2.minutes.ago.iso8601,
            action: "buy",
            market: "INDEX",
            exchange: "NSE",
            current_position: "long",
            previous_position: "flat"
          }
        }
      end

      it "returns status 422 with an error message" do
        post "/api/v1/webhooks/tradingview", params: delayed_payload.to_json, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Invalid or delayed alert")
      end
    end
  end
end
