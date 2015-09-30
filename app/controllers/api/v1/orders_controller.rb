module Api
  module V1
    class OrdersController < ApplicationController
      before_action :can_edit_order

      private

      def can_edit_order
        return if current_user.admin?
        id = params.require(:order_id)
        order = Order.find id
        return if current_user.managed_markets.include?(order.market)
      end
    end
  end
end