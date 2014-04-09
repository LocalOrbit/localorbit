module Admin::Financials
  class InvoicesController < AdminController
    def index
      @orders = Order.orders_for_seller(current_user).uninvoiced.order('orders.placed_at').page(params[:page]).per(params[:per_page])
    end

    def create
      orders = Order.orders_for_seller(current_user).where(id: params[:order_id])
      orders.each {|order| order.invoice! }
      message = "Invoice sent for order #{"number".pluralize(orders.size)} #{orders.map(&:order_number).sort.join(', ')}"
      redirect_to admin_financials_invoices_path, notice: message
    end
  end
end
