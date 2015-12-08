class Api::DashboardBuyerPresenter
  include Dashboards
  include ActiveSupport::NumberHelper

  def initialize(orders, order_items, date_param)
    @orders = orders
    @order_items = order_items
    @date_param = date_param
  end

  def generate

      case @date_param
        when "0"
          interval = Date.today.at_beginning_of_day..Date.today.at_end_of_day
          total_sales_amount_graph = @orders.placed_between(interval).group_by_hour('orders.created_at', format: "%H").order('hour').sum(:total_cost).as_json
          total_order_count_graph = @orders.placed_between(interval).group_by_hour('orders.created_at', format: "%H").count.as_json
        when "1"
          interval = Date.today.at_beginning_of_day - 7..Date.today.at_end_of_day
          total_sales_amount_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").order('day').sum(:total_cost).as_json
          total_order_count_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").count.as_json
        when "2"
          interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
          total_sales_amount_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").order('day').sum(:total_cost).as_json
          total_order_count_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").count.as_json
        when "3"
          interval = Date.new(Date.current.year,1,1).at_beginning_of_day..Date.today.at_end_of_day
          total_sales_amount_graph = @orders.placed_between(interval).group_by_month('orders.created_at', format: "%b").order('month').sum(:total_cost).as_json
          total_order_count_graph = @orders.placed_between(interval).group_by_month('orders.created_at', format: "%b").count.as_json
        else
          interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
          total_sales_amount_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").order('day').sum(:total_cost).as_json
          total_order_count_graph = @orders.placed_between(interval).group_by_day('orders.created_at', format: "%d").count.as_json
      end

      total_sales_amount_raw = @orders.placed_between(interval).sum(:total_cost)
      total_sales_amount = number_to_currency(total_sales_amount_raw, precision:0)
      total_order_count = @orders.placed_between(interval).count

      average_sales_amount = number_to_currency(total_sales_amount_raw/total_order_count || 0, precision:0)

      payments_overdue_orders = @orders.paid_with("purchase order").placed_between(interval).delivered.payment_overdue
      #payments_overdue_amount = number_to_currency(sum_order_total(payments_overdue_orders), precision:0)
      payments_overdue_amount = 0

    {
      :total_sales_amount_graph => total_sales_amount_graph,
      :total_sales_amount => total_sales_amount,
      :total_order_count_graph => total_order_count_graph,
      :total_order_count => total_order_count,
      :average_sales_amount => average_sales_amount,
      :payments_overdue_amount => payments_overdue_amount
    }
  end

end