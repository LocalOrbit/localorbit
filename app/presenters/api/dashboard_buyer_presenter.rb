class Api::DashboardBuyerPresenter
  include Dashboards
  include ActiveSupport::NumberHelper

  def initialize(orders, order_items, date_param)
    @orders = orders
    @order_items = order_items
    @date_param = date_param
  end

  def generate

    total_sales_amount_orders = @orders

    case @date_param
        when "0"
          total_sales_grouped = group_to_buyers(total_sales_amount_orders, 'hour')
        when "1"
          total_sales_grouped = group_to_buyers(total_sales_amount_orders, 'day')
        when "2"
          total_sales_grouped = group_to_buyers(total_sales_amount_orders, 'day')
        when "3"
          total_sales_grouped = group_to_buyers(total_sales_amount_orders, 'month')
        else
          total_sales_grouped = group_to_buyers(total_sales_amount_orders, 'day')
      end

      total_sales_amount_graph = total_sales_grouped[:total].as_json
      total_order_count_graph = total_sales_grouped[:count].as_json

      total_sales_amount_raw = @orders.sum(:total_cost)
      total_sales_amount = number_to_currency(total_sales_amount_raw, precision:0)
      total_order_count = @orders.count

      average_sales_amount = total_order_count > 0 ? number_to_currency(total_sales_amount_raw/total_order_count || 0, precision:0) : '$0'

      payments_due_orders = @orders.paid_with("purchase order").payment_due

      payments_due_amount_raw = sum_order_total(payments_due_orders)
      payments_due_amount = payments_due_amount_raw > 0 ? number_to_currency(payments_due_amount_raw, precision:0) : '$0'

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