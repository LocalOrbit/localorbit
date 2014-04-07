class Admin::PickListsController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate

    order_line_items = if current_user.market_manager?
      @delivery.orders.includes(:items).
        map {|order| order.items }.flatten.group_by(&:product)
    else
      @delivery.orders.joins(items: :product).
        where( products: { organization_id: current_organization.id }).includes(:items).
        map(&:items).flatten.group_by(&:product)
    end

    pick_list_tree = order_line_items.keys.inject({}) do |result, key|
      result[key.organization] = result[key.organization] || {}
      result[key.organization][key] = order_line_items[key]
      result
    end

    @pick_list = pick_list_tree.keys.inject({}) do |result, organization|
      result[organization] = result[organization] || []

      result[organization] = pick_list_tree[organization].keys.map do |product|
        order_items = pick_list_tree[organization][product]

        total = order_items.inject(0) do |memo, line|
         memo += line.quantity
        end

        OpenStruct.new(
          name: product.name,
          total_sold: total,
          unit: total == 1 ? product.unit.singular : product.unit.plural,
          buyers: order_items.map do |line|
            OpenStruct.new(
              name: line.order.organization.name,
              quantity: line.quantity,
              lots: line.lots.select {|lot| lot.number.present? }
            )
          end
        )
      end
      result
    end
  end
end
