module OrdersHelper
  def can_add_products_to_order?(order)
    !order.invoiced? && order.payment_method == "purchase order" &&
      current_user.can_manage_market?(order.market)
  end
end