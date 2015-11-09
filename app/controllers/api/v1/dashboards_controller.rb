module Api
  module V1
    class DashboardsController < ApplicationController

      def index

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
    end
  end
end