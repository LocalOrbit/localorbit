module Api
  module V1
    class DashboardsController < ApplicationController
      include ActiveSupport::NumberHelper
      include Dashboards

      def index

          date_param = params[:dateRange]
          view_as = params[:viewAs]

          show_entity_picker = current_user.admin_or_mm? && current_user.seller?

          if show_entity_picker
            user_type = nil
          elsif current_user.seller?
            view_as = nil
            user_type = "S"
          else
            view_as = nil
            user_type = "B"
          end

          case date_param
            when "0"
              interval = Date.today.at_beginning_of_day..Date.today.at_end_of_day
            when "1"
              interval = Date.today.at_beginning_of_day - 7..Date.today.at_end_of_day
            when "2"
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
            when "3"
              interval = Date.new(Date.current.year,1,1).at_beginning_of_day..Date.today.at_end_of_day
            else
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
          end

          if view_as == "B" || user_type == "B"
            orders = Order.placed_between(interval).where(market: current_market)
            order_items = nil
            @presenter = DashboardBuyerPresenter.new(orders, order_items, date_param).generate
          else
            orders = Order.placed_between(interval).orders_for_seller(current_user)
            order_items = nil
            @presenter = DashboardSellerPresenter.new(orders, order_items, date_param).generate
          end

          upcomingDeliveries = upcoming_deliveries

          pending_delivery_amount = "$1"

          render json: {dashboard: {userType: user_type, showEntityPicker: show_entity_picker, deliveries: upcomingDeliveries[:deliveries], numPendingDeliveries: upcomingDeliveries[:numUpcomingDeliveries], pendingDeliveryAmount: pending_delivery_amount, totalSalesAmount: @presenter[:total_sales_amount], totalSalesAmountGraph: @presenter[:total_sales_amount_graph], totalOrderCount: @presenter[:total_order_count], totalOrderCountGraph: @presenter[:total_order_count_graph], avgSalesAmount: @presenter[:average_sales_amount], paymentsDueAmount: @presenter[:payments_due_amount], paymentsOverdueDueAmount: @presenter[:payments_overdue_amount]}}
      end

      def timezone
        Time.zone
      end

    end
  end
end