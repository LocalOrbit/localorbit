module Admin::Financials
  class InvoicesController < AdminController
    def index
      @orders = Order.orders_for_seller(current_user).uninvoiced.order('orders.placed_at').page(params[:page]).per(params[:per_page])
    end

    def create
      orders = Order.orders_for_seller(current_user).uninvoiced.where(id: params[:order_id])
      # TODO: Figure out what to do if the save fails
      # The order would have to become invalid after being placed.
      orders.each {|order| order.invoice! }
      message = "Invoice sent for order #{"number".pluralize(orders.size)} #{orders.map(&:order_number).sort.join(', ')}"
      redirect_to admin_financials_invoices_path, notice: message
    end
  end
end
