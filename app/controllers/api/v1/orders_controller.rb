module Api
  module V1
    class OrdersController < ApplicationController
      before_action :can_edit_order

      private

      def can_edit_order
        id = params.require(:order_id)
        order = Order.find id
        return if FeatureAccess.can_edit_order?(user: current_user, order: order)
      end
    end
  end
end