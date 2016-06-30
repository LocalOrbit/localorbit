class Admin::PickListsController < AdminController

  # basically want ids of all deliveries with the same delivery_date_heading
  def get_deliveries(decorated_delivery)
    delivs = []
    markd = decorated_delivery.upcoming_delivery_date_heading
    decorated_delivery.delivery_schedule.deliveries.each do |deliv|
      deliv = deliv.decorate
      if deliv.upcoming_delivery_date_heading == markd
        delivs << deliv
      end
    end
    if delivs.empty?
      delivs = [decorated_delivery]
    end
    delivs.map(&:id)
  end

  def show
    # binding.pry
    @delivery = Delivery.find(params[:id]).decorate
    # @delivery_schedule = @delivery.delivery_schedule

    # unique = {seller_start:@delivery_schedule.seller_delivery_start, seller_loc:@delivery_schedule.seller_fulfillment_location_id,seller_display_date:@delivery.seller_display_date} # fulfillment location id should never be 0 if it comes up on a delivery

    @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)

    # need a method / functionality to handle the view such that they're grouped by the day/time uniqueness with location as desired for consolidated (seller display date on decorated delivery) -- how will the view handle it for show, looks to be iterating on deliveries instead of pick lists?

    order_items = OrderItem.where(delivery_status: "pending", orders: {delivery_id: get_deliveries(@delivery)})
                    .eager_load(:order, product: :organization)
                    .order("organizations.name, products.name")
                    .preload(order: :organization)

    @delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    
    unless @very_important_person
      order_items = order_items.where(products: {organization_id: current_user.organization_ids})
    end

    # want this to be grouped by the unique pieces?
    # no: should always be grped by org, just consolidated re: deliveries
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
