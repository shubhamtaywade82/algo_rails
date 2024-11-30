class OrdersController < ApplicationController
  def index
    orders = OrdersService.call
    render json: orders
  end

  def create
    order_params = params.permit(:dhanClientId, :transactionType, :exchangeSegment, :productType, :orderType, :validity, :securityId, :quantity)
    result = OrdersService.call(order_params)
    render json: result
  end
end
