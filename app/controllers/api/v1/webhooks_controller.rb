module Api
  module V1
    class WebhooksController < ApplicationController
      def tradingview
        if valid_alert?(alert_params)
          alert = Alert.create(alert_params.except(:trailing_stop_loss).merge(status: "pending"))

          if alert.persisted?
            Alerts::ProcessTradingAlertService.call(alert)
            render json: { message: "Alert processed successfully", alert: alert }, status: :ok
          else
            render json: { error: "Failed to save alert", details: alert.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Invalid or delayed alert" }, status: :unprocessable_entity
        end
      end

      private

      def valid_alert?(alert)
        # Ensure the alert time is within the last 60 seconds
        Time.now.utc - Time.parse(alert[:time]) < 60
      rescue ArgumentError
        false
      end

      def alert_params
        params.require(:webhook).permit(
          :ticker,
          :close,
          :time,
          :volume,
          :action,
          :market,
          :exchange,
          :current_position,
          :previous_position,
          :trailing_stop_loss
        )
      end
    end
  end
end
