class FundsController < ApplicationController
  def show
    funds = fetch_funds_details
    if funds
      render json: { funds: funds }, status: :ok
    else
      render json: { error: "Unable to fetch funds details" }, status: :unprocessable_entity
    end
  end

  private

  def fetch_funds_details
    begin
      Dhanhq::Api::Funds.fund_limit
    rescue StandardError => e
      Rails.logger.error("Error fetching funds details: #{e.message}")
      nil
    end
  end
end
