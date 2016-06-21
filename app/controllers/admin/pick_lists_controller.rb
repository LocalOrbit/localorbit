class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate
    @delivery_schedule = @delivery.delivery_schedule
    # @delivery = @delivery.decorate 
    unique = {seller_start:@delivery_schedule.seller_delivery_start, seller_loc:@delivery_schedule.seller_fulfillment_location_id} # fulfillment location id should never be 0 if it comes up on a delivery


    @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)

    order_items = OrderItem.where(delivery_status: "pending", orders: {delivery_id: @delivery.id})
                    .eager_load(:order, product: :organization)
                    .order("organizations.name, products.name")
                    .preload(order: :organization)
    # binding.pry

    @delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    
    unless @very_important_person
      order_items = order_items.where(products: {organization_id: current_user.organization_ids})
    end

    # want this to be grouped by the unique pieces

    @pick_lists = order_items.group_by {|item| item.product.organization_id}.map do |_, items|
      PickListPresenter.new(items, @delivery_notes)
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
