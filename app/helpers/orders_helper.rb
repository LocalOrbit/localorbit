module OrdersHelper
  def can_add_products_to_order?(order, user_order_context)
    ((!order.invoiced? && order.payment_method == "purchase order") || (order.payment_method == "credit card")) && FeatureAccess.order_action_links?(user_order_context: user_order_context)
  end
end
