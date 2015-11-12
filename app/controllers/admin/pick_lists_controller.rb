class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate
    @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)

    order_items = OrderItem.where(delivery_status: "pending", orders: {delivery_id: @delivery.id})
                    .eager_load(:order, product: :organization)
                    .order("organizations.name, products.name")
                    .preload(order: :organization)

    unless @very_important_person
      order_items = order_items.where(products: {organization_id: current_user.organization_ids})
    end

    @pick_lists = order_items.group_by {|item| item.product.organization_id }.map do |_, items|
      PickListPresenter.new(items)
    end

    if @pick_lists.empty?
      render_404
    else
      respond_to do |format|
        format.html
        format.csv { @filename = "pick-list.csv" }
      end
    end
  end
end
