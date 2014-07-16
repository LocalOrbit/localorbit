class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate

    order_line_items = if current_user.market_manager? || current_user.admin?
      @delivery.orders.undelivered_order_items_by_product
    else
      @delivery.orders.undelivered_order_items_by_product_for_organization(current_organization)
    end

    @pick_list = PickListPresenter.build(order_line_items)
  end
end
