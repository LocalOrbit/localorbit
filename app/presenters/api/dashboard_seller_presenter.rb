class Api::DashboardSellerPresenter
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
        total_sales_amount_orders = @orders.placed_between(interval)
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'hour')
      when "1"
        interval = Date.today.at_beginning_of_day - 7..Date.today.at_end_of_day
        total_sales_amount_orders = @orders.placed_between(interval)
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day')
      when "2"
        interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
        total_sales_amount_orders = @orders.placed_between(interval)
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day')
      when "3"
        interval = Date.new(Date.current.year,1,1).at_beginning_of_day..Date.today.at_end_of_day
        total_sales_amount_orders = @orders.placed_between(interval)
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'month')
      else
        interval = Date.new(Date.current.year,Date.current.month,1).at_beginning_of_day..Date.today.at_end_of_day
        total_sales_amount_orders = @orders.placed_between(interval)
        total_sales_grouped = group_to_sellers(total_sales_amount_orders, 'day')
    end

    total_sales_amount_graph = total_sales_grouped[:total].as_json
    total_order_count_graph = total_sales_grouped[:count].as_json

    total_sales_orders = @orders.placed_between(interval)
    total_order_count = @orders.placed_between(interval).count

    total_sales_amount_raw = sum_money_to_sellers(total_sales_orders)
    total_sales_amount = number_to_currency(total_sales_amount_raw, precision:0)

    average_sales_amount = number_to_currency(total_sales_amount_raw/total_order_count || 0, precision:0)


    payments_orders = @orders.paid_with("purchase order").delivered.paid_between(interval)
    payments_due_amount = number_to_currency(sum_money_to_sellers(payments_orders), precision:0)

    {
      :total_sales_amount_graph => total_sales_amount_graph,
      :total_sales_amount => total_sales_amount,
      :total_order_count_graph => total_order_count_graph,
      :total_order_count => total_order_count,
      :average_sales_amount => average_sales_amount,
      :payments_due_amount => payments_due_amount
    }

  end

end