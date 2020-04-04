module Api
  module V1
    class DashboardsController < ApplicationController
      include ActiveSupport::NumberHelper
      include Dashboards
      include Users
      include ApplicationHelper

      def index

          date_param = params[:dateRange]
          view_as = params[:viewAs]

          show_entity_picker = !current_user.admin_or_mm? && current_user.seller?

          user_type = nil

          if current_user.admin_or_mm?
            user_type = "M"
          elsif current_user.seller?
            user_type = "S"
          elsif !current_user.admin_or_mm? && current_user.buyer_only?
            user_type = "B"
          end

          if show_entity_picker
            if view_as == "B"
              user_type = "B"
            else
              user_type = "S"
            end
          end

          case date_param
            when "0"
              interval = Date.today.at_beginning_of_day..Date.today.at_end_of_day
              axisTitle = 'Hour of Day'
            when "1"
              interval = Date.today.at_beginning_of_day - 6.day..Date.today.at_end_of_day
              axisTitle = 'Last 7 Days'
            when "2"
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
              axisTitle = 'Day of Month'
            when "3"
              interval = Date.new(Date.current.year,1,1).at_beginning_of_day..Date.today.at_end_of_day
              axisTitle = 'Month of Year'
            else
              interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
              axisTitle = 'Day of Month'
          end

          if user_type == "M"
            orders = Order.orders_for_seller(current_user).where(market: current_market).order(:created_at)
            payments_due_orders = orders.paid_with("purchase order").delivered.payment_overdue + orders.paid_with("purchase order").invoiced.unpaid.payment_due
            @presenter = DashboardMarketManagerPresenter.new(orders, payments_due_orders, date_param, interval).generate
          elsif user_type == "B"
            orders = Order.orders_for_buyer(current_user).where(market: current_market).order(:created_at)
            payments_due_orders = orders.paid_with("purchase order").payment_overdue + orders.paid_with("purchase order").payment_due
            @presenter = DashboardBuyerPresenter.new(orders, payments_due_orders, date_param, interval).generate
          else
            orders = Order.orders_for_seller(current_user).where(market: current_market).order(:created_at)
            @presenter = DashboardSellerPresenter.new(orders, interval, date_param, current_user).generate
          end

          num_pending_buyers = 0
          if user_type == "M"
            num_pending_buyers = find_users.where('confirmation_sent_at IS NOT NULL AND confirmed_at IS NULL').count
          end

          upcoming_dlvr = upcoming_deliveries(user_type)

          fillColor = hex_to_rgba(current_market.text_color,0.2)
          lineColor = hex_to_rgba(current_market.text_color,1)

          render json: {dashboard: {userType: user_type, axisTitle: axisTitle, fillColor: fillColor, lineColor: lineColor, showEntityPicker: show_entity_picker, deliveries: upcoming_dlvr[:deliveries], numPendingDeliveries: upcoming_dlvr[:numPendingDeliveries], pendingDeliveryAmount: upcoming_dlvr[:pendingDeliveryAmount], totalSalesAmount: @presenter[:total_sales_amount], graphLabels: @presenter[:graph_labels], totalSalesAmountGraph: @presenter[:total_sales_amount_graph], totalOrderCount: @presenter[:total_order_count], totalOrderCountGraph: @presenter[:total_order_count_graph], avgSalesAmount: @presenter[:average_sales_amount], paymentsDueAmount: @presenter[:payments_due_amount], numPendingBuyers: num_pending_buyers}}
      end

      def timezone
        Time.zone
      end

    end
  end
end