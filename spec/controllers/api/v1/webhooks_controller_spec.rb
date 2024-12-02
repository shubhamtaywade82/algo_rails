require 'rails_helper'

RSpec.describe Api::V1::WebhooksController, type: :controller do
  let(:valid_index_buy_params) do
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

  let(:valid_stock_sell_params) do
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

  let(:invalid_params) do
    {
      webhook: {
        ticker: nil,
        close: nil,
        time: nil,
        action: "buy",
        market: "INDEX",
        exchange: "NSE",
        current_position: "long",
        previous_position: "flat"
      }
    }
  end

  describe "POST #tradingview" do
    context "with valid INDEX buy alert" do
      it "creates an alert and processes it" do
        expect do
          post :tradingview, params: valid_index_buy_params
        end.to change(Alert, :count).by(1)

        expect(response).to have_http_status(:ok)
        alert = Alert.last
        expect(alert.ticker).to eq("NIFTY")
        expect(alert.status).to eq("pending")
      end
    end

    context "with valid STOCK sell alert" do
      it "creates an alert and processes it" do
        expect do
          post :tradingview, params: valid_stock_sell_params
        end.to change(Alert, :count).by(1)

        expect(response).to have_http_status(:ok)
        alert = Alert.last
        expect(alert.ticker).to eq("INDIANB")
        expect(alert.status).to eq("pending")
      end
    end

    context "with invalid parameters" do
      it "does not create an alert and returns status 422" do
        expect do
          post :tradingview, params: invalid_params
        end.not_to change(Alert, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Invalid or delayed alert")
      end
    end

    context "with delayed alert" do
      it "does not create an alert and returns status 422" do
        delayed_params = {
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

        expect do
          post :tradingview, params: delayed_params
        end.not_to change(Alert, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Invalid or delayed alert")
      end
    end
  end
end
