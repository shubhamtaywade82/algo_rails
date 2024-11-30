# app/services/orders_service.rb

class OrdersService < ApplicationService
  def initialize(order_params = {})
    @client = Dhanhq::Api::Orders
    @order_params = order_params
  end

  # The main entry point for the service
  #
  # @return [Object] Result of the desired operation
  def call
    if @order_params.empty?
      fetch_orders
    else
      place_order
    end
  end

  private

  # Fetches all orders from the Dhan API
  #
  # @return [Array<Hash>] List of orders
  def fetch_orders
    @client.orders_list
  rescue StandardError => e
    handle_error(e)
  end

  # Places a new order using the Dhan API
  #
  # @return [Hash] The response of the API
  def place_order
    @client.place_order(@order_params)
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(error)
    Rails.logger.error("Dhan API Error: #{error.message}")
    { error: error.message }
  end
end
