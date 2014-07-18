class PickListPresenter
  def self.build(current_user, current_organization, delivery)
    # The condition combined with the eager_load will result
    # in loaded items lists that only include pending deliveries
    scope = delivery.orders.where(order_items: {delivery_status: "pending"}).eager_load(items: {product: :organization})
    if !(current_user.market_manager? || current_user.admin?)
      scope = scope.where(products: {organization_id: current_organization.id})
    end

    order_items = scope.map(&:items).flatten
    order_items.sort! do |a,b|
      s1 = a.product.organization.name.casecmp(b.product.organization.name)
      next(s1) unless s1 == 0
      a.product.name.casecmp(b.product.name)
    end

    pick_list_tree = order_items.inject({}) do |result, item|
      result[item.product.organization] ||= {}
      (result[item.product.organization][item.product] ||= []) << item
      result
    end

    pick_list_tree.keys.inject({}) do |result, organization|
      result[organization] = result[organization] || []

      result[organization] = pick_list_tree[organization].keys.map do |product|
        order_items = pick_list_tree[organization][product]

        total = order_items.sum(&:quantity)

        OpenStruct.new(
          name: product.name,
          total_sold: total,
          unit: total == 1 ? product.unit_singular : product.unit_plural,
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
