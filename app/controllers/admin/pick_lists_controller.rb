class Admin::PickListsController < AdminController
  def show
    if !params[:id].nil?
      @delivery = Delivery.find(params[:id]).decorate

      order_items = OrderItem.where(delivery_status: "pending", orders: {delivery_id: @delivery.id})
                    .eager_load(:order, product: :organization)
                    .order("organizations.name, products.name")
                    .preload(order: :organization)
      @delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
      @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)
      unless @very_important_person
        order_items = order_items.where(products: {organization_id: current_user.organization_ids})
      end

      @pick_lists = order_items.group_by {|item| item.product.organization_id }.map do |_, items|
        PickListPresenter.new(items, @delivery_notes)
      end

    else

      dt = params[:deliver_on].to_date
      dte = dt.strftime("%Y-%m-%d")

      @delivery = Delivery.joins(:delivery_schedule)
                      .where("DATE(deliveries.buyer_deliver_on) = '#{dte}'")
                      .where(delivery_schedules: {market_id: current_market.id}).first
                      .decorate

      order_items = OrderItem
                        .where(delivery_status: "pending")
                        .where("DATE(deliveries.buyer_deliver_on) = '#{dte}'")
                        .where(orders: {market_id: current_market.id})
                        .eager_load(:order, order: [:delivery], product: :organization)
                        .order("organizations.name, products.name")
                        .preload(order: :organization)

      @delivery_notes = DeliveryNote.joins(:order).where(order: order_items.map(&:order_id))

      @pick_lists = order_items.group_by {|item| item.product.organization_id }.map do |_, items|
        PickListPresenter.new(items, @delivery_notes)
      end

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
