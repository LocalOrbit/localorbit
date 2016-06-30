class Admin::PickListsController < AdminController
  def show
    binding.pry
    @delivery = Delivery.find(params[:id]).decorate
    @delivery_schedule = @delivery.delivery_schedule
    # @delivery = @delivery.decorate 
    unique = {seller_start:@delivery_schedule.seller_delivery_start, seller_loc:@delivery_schedule.seller_fulfillment_location_id} # fulfillment location id should never be 0 if it comes up on a delivery

    # must be on that delivery schedule
    # so, deliveries on that delivery schedule with a delivery id that 

    @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)

    # need a method to get the SET of deliveries to look through in order to create the order items

    # also, need a method / functionality to handle the view such that they're grouped by the day/time uniqueness with location as desired for consolidated

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
