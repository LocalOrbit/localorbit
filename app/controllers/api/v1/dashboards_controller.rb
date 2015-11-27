module Api
  module V1
    class DashboardsController < ApplicationController

      def index

        deliveries = upcoming_deliveries

        #interval = params[:interval]
        interval = Date.new(Date.current.year,1,1)..Date.today

        total_sales_amount = Order.where(market: current_market).placed_between(interval).sum(:total_cost).as_json
        total_sales_amount_graph = Order.where(market: current_market).placed_between(interval).group_by_month(:created_at, format: "%b").sum(:total_cost).as_json

        total_order_count= Order.where(market: current_market).placed_between(interval).count.as_json
        total_order_count_graph = Order.where(market: current_market).placed_between(interval).group_by_month(:created_at, format: "%b").count.as_json

        #totalSalesGraph = Order.orders_for_buyer(@user).where(market: @market).placed_between(interval).as_json()

        render json: {dashboard: {totalSalesAmount: total_sales_amount, totalSalesAmountGraph: total_sales_amount_graph, totalOrderCount: total_order_count, totalOrderCountGraph: total_order_count_graph}}
        #render json: {dashboard: {totalSales: 4321}}
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
    end
  end
end