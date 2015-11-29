module Api
  module V1
    class DashboardsController < ApplicationController
      include ActiveSupport::NumberHelper

      def index

        date_param = params[:dateRange]

        orders = Order.where(market: current_market)
        order_items = Order.where(market: current_market).joins(:items)

        interval = nil
        total_sales_amount_graph = nil
        total_order_count_graph = nil

        case date_param
          when "0"
            interval = Date.today..Date.today
            total_sales_amount_graph = orders.placed_between(interval).group_by_hour(:created_at, format: "%H").order('hour').sum(:total_cost).as_json
            total_order_count_graph = orders.placed_between(interval).group_by_hour(:created_at, format: "%H").count.as_json
          when "1"
            interval = Date.today - 7..Date.today
            total_sales_amount_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").order('day').sum(:total_cost).as_json
            total_order_count_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").count.as_json
          when "2"
            interval = Date.new(Date.current.year,Date.current.month,1)..Date.today
            total_sales_amount_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").order('day').sum(:total_cost).as_json
            total_order_count_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").count.as_json
          when "3"
            interval = Date.new(Date.current.year,1,1)..Date.today
            total_sales_amount_graph = orders.placed_between(interval).group_by_month(:created_at, format: "%b").order('month').sum(:total_cost).as_json
            total_order_count_graph = orders.placed_between(interval).group_by_month(:created_at, format: "%b").count.as_json
        else
          interval = Date.new(Date.current.year,Date.current.month,1)..Date.today
          total_sales_amount_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").order('day').sum(:total_cost).as_json
          total_order_count_graph = orders.placed_between(interval).group_by_day(:created_at, format: "%d").count.as_json
        end

        deliveries = upcoming_deliveries

        total_sales_amount = number_to_currency(orders.placed_between(interval).sum(:total_cost), precision:0)
        average_sales_amount = number_to_currency(orders.placed_between(interval).average(:total_cost), precision:0)
        payments_orders = order_items.paid_with("purchase order").delivered.paid_between(interval)
        payments_due_amount = number_to_currency(sum_money_to_sellers(payments_orders), precision:0)
        total_order_count = orders.placed_between(interval).count

        render json: {dashboard: {deliveries: deliveries, totalSalesAmount: total_sales_amount, totalSalesAmountGraph: total_sales_amount_graph, totalOrderCount: total_order_count, totalOrderCountGraph: total_order_count_graph, avgSalesAmount: average_sales_amount, paymentsDueAMount: payments_due_amount}}
      end

      private

      def upcoming_deliveries
        @deliveries = current_market.delivery_schedules.visible.
            map {|ds| ds.next_delivery.decorate(context: {current_organization: current_organization}) }.
            sort_by {|d| d.deliver_on }

        first_delivery = @deliveries.first.buyer_deliver_on
        last_delivery = first_delivery + 30.days
        delivery_for_day = @deliveries.each_with_object({}) { |d,map| map[d.buyer_deliver_on.wday] ||= d }

        now = DateTime.now
        calendar_start = now - now.wday
        calendar_end = last_delivery + (6 - last_delivery.wday)

        delivery_weeks = [ [] ]

        (calendar_start..calendar_end).each { |day|
          delivery_id = nil
          css_class = if day < first_delivery || last_delivery < day
                        "cal-date disabled"
                      elsif delivery_for_day[day.wday]
                        delivery_id = delivery_for_day[day.wday].id
                        "cal-date"
                      else
                        "cal-date disabled"
                      end
          if delivery_weeks[-1].length == 7
            delivery_weeks.push [ ]
          end
          delivery_weeks[-1].push({ day: day, css_class: css_class, delivery_id: delivery_id })
        }
      end

      def sum_money_to_sellers(orders)
        orders.inject(0) do |total, order|
          total + order.items.map(&:seller_net_total).reduce(:+)
        end
      end
    end
  end
end