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
    else

      dt = params[:deliver_on].to_date

      if params[:market_id].nil?
        market_id = current_market.id
      else
        market_id = params[:market_id]
      end

      if current_user.buyer_only? || current_user.market_manager?
        d_scope = {deliveries: {buyer_deliver_on: dt.beginning_of_day..dt.end_of_day}}
      else
        d_scope = {deliveries: {deliver_on: dt.beginning_of_day..dt.end_of_day}}
      end

      @delivery = Delivery.joins(:delivery_schedule)
                      .where(d_scope)
                      .where(delivery_schedules: {market_id: market_id}).first
                      .decorate

      order_items = OrderItem
                        .where(delivery_status: "pending")
                        .where(d_scope)
                        .where(orders: {market_id: market_id})
                        .eager_load(:order, order: [:delivery], product: :organization)
                        .order("organizations.name, products.name")
                        .preload(order: :organization)

      @delivery_notes = DeliveryNote.joins(:order).where(order: order_items.map(&:order_id))
      @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)
      unless @very_important_person
        order_items = order_items.where(products: {organization_id: current_user.organization_ids})
      end
    end
    @pick_lists = order_items.group_by {|item| item.product.organization_id }.map do |_, items|
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
