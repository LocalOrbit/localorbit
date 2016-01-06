module Api
  module V1
    class DashboardsController < ApplicationController
      include ActiveSupport::NumberHelper
      include Dashboards
      include Users

      def index

          date_param = params[:dateRange]
          view_as = params[:viewAs]

          show_entity_picker = !current_user.admin_or_mm? && current_user.seller?

          if show_entity_picker
            user_type = nil
          else
              if current_user.admin_or_mm?
                view_as = nil
                user_type = "M"
              elsif current_user.seller?
                view_as = nil
                user_type = "S"
              elsif !current_user.admin_or_mm?
                view_as = nil
                user_type = "B"
              end
          end
          case date_param
            when "0"
              interval = Date.today.at_beginning_of_day..Date.today.at_end_of_day
            when "1"
              interval = Date.today.at_beginning_of_day - 7.day..Date.today.at_end_of_day
            when "2"
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
            when "3"
              interval = Date.new(Date.current.year,1,1).at_beginning_of_day..Date.today.at_end_of_day
            else
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
          end

          if view_as == "B" || user_type == "B" || user_type == "M"
            orders = Order.placed_between(interval).dashboard_orders_for_buyer(current_user).order(:created_at)
            order_items = nil
            @presenter = DashboardBuyerPresenter.new(orders, order_items, date_param).generate
          else
            orders = Order.placed_between(interval).orders_for_seller(current_user).order(:id)
            order_items = nil
            @presenter = DashboardSellerPresenter.new(orders, order_items, interval, date_param).generate
          end

          num_pending_buyers = 0
          if user_type == "M"
            num_pending_buyers = find_users.where('confirmation_sent_at IS NOT NULL AND confirmed_at IS NULL').count
          end

          upcoming_dlvr = upcoming_deliveries(user_type)

          render json: {dashboard: {userType: user_type, showEntityPicker: show_entity_picker, deliveries: upcoming_dlvr[:deliveries], numPendingDeliveries: upcoming_dlvr[:numPendingDeliveries], pendingDeliveryAmount: upcoming_dlvr[:pendingDeliveryAmount], totalSalesAmount: @presenter[:total_sales_amount], totalSalesAmountGraph: @presenter[:total_sales_amount_graph], totalOrderCount: @presenter[:total_order_count], totalOrderCountGraph: @presenter[:total_order_count_graph], avgSalesAmount: @presenter[:average_sales_amount], paymentsDueAmount: @presenter[:payments_due_amount], numPendingBuyers: num_pending_buyers}}
      end

      def timezone
        Time.zone
      end

    end
  end
end