module Api
  module V1
    class WebhooksController < ApplicationController
      def tradingview
        if valid_alert?(alert_params)
          # ProcessTradingAlertService.call(alert)

          render json: { message: "Alert processed successfully", alert: alert_params }, status: :ok
        else
          render json: { error: "Invalid or delayed alert" }, status: :unprocessable_entity
        end
      end

      private

      def valid_alert?(alert)
        # Alert within 60 seconds
        Time.now - Time.parse(alert[:timestamp]) < 60
      end

      def alert_params
        params.require(:webhook).permit(:symbol, :action, :price, :timestamp)
      end
    end
  end
end
