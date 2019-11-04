class Admin::LoadListController < AdminController
  def show
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")

    if params[:market_id].nil?
      market_id = current_market.id
    else
      market_id = params[:market_id]
    end

    d_scope = "DATE(deliveries.buyer_deliver_on) = '#{dte}'"

    @delivery = Delivery.joins(:delivery_schedule)
                    .where(d_scope)
                    .where(delivery_schedules: {market_id: market_id}).first

    if @delivery.nil?
      render_404
      return
    end

    @buyer_deliver_on = dt.strftime("%A %B %e, %Y")
    @delivery = @delivery.decorate

    order_items = OrderItem
                      .where(delivery_status: "pending")
                      .where(d_scope)
                      .where(orders: {market_id: market_id})
                      .includes({order: [:organization, {delivery: :delivery_schedule}], product: :organization})
                      .order("deliveries.buyer_deliver_on, organizations.name, products.name")
    @very_important_person = current_user.admin? || current_user.managed_market_ids.include?(@delivery.delivery_schedule.market_id)
    unless @very_important_person
      order_items = order_items.where(products: {organization_id: current_user.organization_ids})
    end

    @load_lists = order_items.group_by {|item| item.order.delivery_id }.map do |_, items|
      LoadListPresenter.new(items)
    end

    if @load_lists.empty?
      render_404
    else
      respond_to do |format|
        format.html
        format.csv { @filename = "load-list.csv" }
      end
    end
  end
end
